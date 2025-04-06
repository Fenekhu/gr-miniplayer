import 'dart:async';

import 'package:gr_miniplayer/util/exceptions.dart';
import 'package:gr_miniplayer/util/lib/shared_prefs.dart';
import 'package:gr_miniplayer/data/service/station_api.dart';
import 'package:result_dart/result_dart.dart';

// A collection of methods for accessing the persistent user session data in sharedPrefs.
// Those stored values only need to be accessed from this file, so its okay to put them here like this.

String _getStored(String key) => sharedPrefs.containsKey(key) ? sharedPrefs.getString(key) ?? '' : '';
Future<void> _setStored(String key, String value) => sharedPrefs.setString(key, value);

String _getStoredUserID() => _getStored('user.id');
Future<void> _setStoredUserID(String userID) => _setStored('user.id', userID);

String _getStoredUsername() => _getStored('user.name');
Future<void> _setStoredUsername(String username) => _setStored('user.name', username);

String _getStoredAsi() => _getStored('user.asi');
Future<void> _setStoredAsi(String asi) => _setStored('user.asi', asi);

String _getStoredApiKey() => _getStored('user.apiKey');
Future<void> _setStoredApiKey(String apiKey) => _setStored('user.apiKey', apiKey);

/// Represents the current user session information (as returned from the login API).
class UserSessionData {
  final String userID;
  final String username;
  final String asi;
  final String apiKey;

  const UserSessionData({required this.userID, required this.username, required this.asi, required this.apiKey});
  const UserSessionData.empty() : this(userID: '', username: '', asi: '', apiKey: '');
  /// loads the session information from persistent storage
  UserSessionData.fromStorage() : this(userID: _getStoredUserID(), username: _getStoredUsername(), asi: _getStoredAsi(), apiKey: _getStoredApiKey());

  bool get isLoggedIn => asi.isNotEmpty;

  /// stores this session information to persistent storage.
  Future<void> store() async {
    await Future.wait([ // allows these to happen in any order/"simultaneously"
      _setStoredUserID(userID),
      _setStoredUsername(username),
      _setStoredAsi(asi),
      _setStoredApiKey(apiKey),
    ]);
  }
}

/// The rating and favorite status for a user for a song.
/// These are bundled together because they are both provided by a single API endpoint.
class RatingFavoriteStatus {
  final int? rating;
  final int? year;
  final bool favorite;

  const RatingFavoriteStatus({required this.rating, required this.year, required this.favorite});
  const RatingFavoriteStatus.empty() : this(rating: null, year: null, favorite: false);
}

/// Provides data related to information that depends on the user session.
class UserResources {

  UserResources({required StationApiClient apiClient})
    : _apiClient = apiClient,
      _needsLoginPageController = StreamController.broadcast(),
      _userDataStreamController = StreamController.broadcast(),
      _ratingFavoriteStreamController = StreamController.broadcast() {
        _userDataStreamController.add(UserSessionData.fromStorage());
      }

  /// underlying service.
  final StationApiClient _apiClient;

  final StreamController<bool> _needsLoginPageController;
  final StreamController<UserSessionData> _userDataStreamController;
  final StreamController<RatingFavoriteStatus> _ratingFavoriteStreamController;

  // to prevent duplicated API calls after hot reloading.
  String? _lastFetchedStatusSongID;
  String? _lastSubmittedRatingSongID;
  int? _lastSubmittedRatingScore;
  String? _lastSubmittedFavoriteSongID;
  bool? _lastSubmittedFavoriteState;

  RatingFavoriteStatus _cachedRatingFavoriteStatus = RatingFavoriteStatus.empty();

  /// Whether to show the login page (true) or the album art (false)
  Stream<bool> get needsLoginPageStream => _needsLoginPageController.stream; // used for communicating pressing the "Login" button across widgets
  /// Provides UserSessionData after a successful login, or empty user data after a logout.
  Stream<UserSessionData> get userDataStream => _userDataStreamController.stream;
  /// Provides the rating and favorite status of songs. Events are sent though after a call to either updateRatingFavoriteStatus or submitRating.
  Stream<RatingFavoriteStatus> get ratingFavoriteStream => _ratingFavoriteStreamController.stream;

  bool get isLoggedIn => _getStoredAsi().isNotEmpty;

  set needsLoginPage(bool value) => _needsLoginPageController.add(value);

  Future<void> dispose() async {
    await Future.wait([
      _needsLoginPageController.close(),
      _userDataStreamController.close(),
      _ratingFavoriteStreamController.close(),
    ]);
  }

  /// Logs in with the given credentials.
  AsyncResult<Unit> login(String username, String password) async {
    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<LoginResponse> result;
    try {
      result = await _apiClient.login(username, password);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the successful result: 
    //     store the asi and api key for persistent sessions.
    //     transform it into a UserSessionData object.
    //     add it to the user data state stream
    return result.toAsyncResult()
      .map((lr) async {
        final userData = UserSessionData(
          userID: lr.userID, 
          username: lr.username, 
          asi: lr.asi, 
          apiKey: lr.apiKey,
        );
        await userData.store();
        _userDataStreamController.add(userData);
        return unit;
      });
    // rating and favorite status will be updated by RatingFavoriteBridge in response to data on the userDataStream
  }

  /// Logs out, clearing all user information.
  Future<void> logout() async {
    final userData = UserSessionData.empty();
    await userData.store();
    _userDataStreamController.add(userData);
    // rating and favorite status will be updated by RatingFavoriteBridge in response to data on the userDataStream
  }

  /// Gets the current rating information and favorite status of the song.
  /// Note that the server requires songID match the currently playing song.
  AsyncResult<Unit> updateRatingAndFavoriteStatus(String songID) async {
    // early exit if not logged in and emit empty status
    if (_getStoredAsi().isEmpty) {
      _cachedRatingFavoriteStatus = RatingFavoriteStatus.empty();
      _ratingFavoriteStreamController.add(_cachedRatingFavoriteStatus);
      return Success(unit);
    }
    // early exit if the status of this song has already been fetched.
    if (songID == _lastFetchedStatusSongID) {
      return Success(unit);
    }

    _lastFetchedStatusSongID = songID;

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<RatingResponse> result;
    try {
      result = await _apiClient.getRatingAndFavorited(_getStoredAsi(), songID);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the succesful result, transforming it into a RatingFavoriteStatus object.
    return result
      .map((resp) {
        _cachedRatingFavoriteStatus = RatingFavoriteStatus(
          rating: resp.rating, 
          year: resp.year, 
          favorite: resp.favorite,
        );
        _ratingFavoriteStreamController.add(_cachedRatingFavoriteStatus);
        return unit;
      })
      .onFailure((failure) {
        _cachedRatingFavoriteStatus = RatingFavoriteStatus.empty();
        _ratingFavoriteStreamController.add(_cachedRatingFavoriteStatus);
      });
  }

  AsyncResult<Unit> submitRating(String songID, int rating) async {
    // throw if rating is an invalid value somehow
    if (rating < 1 || rating > 5) throw RangeError.range(rating, 1, 5, 'rating');
    // early exit if not logged in.
    if (_getStoredAsi().isEmpty) return Failure(NotLoggedInException('Must be logged in to rate songs'));
    // early exit if rating already submitted or rating matches current rating.
    if ((_lastSubmittedRatingSongID == songID && _lastSubmittedRatingScore == rating) 
      || _cachedRatingFavoriteStatus.rating == rating) {
        return Success(unit);
      }

    _lastSubmittedRatingSongID = songID;
    _lastSubmittedRatingScore = rating;

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<Unit> result;
    try {
      result = await _apiClient.submitRating(_getStoredAsi(), songID, rating);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // emit the updated status to the stream
    return result.onSuccess((_) {
      _cachedRatingFavoriteStatus = RatingFavoriteStatus(
        rating: rating, 
        year: DateTime.now().year, // note that the user may modify the date on their machine. This is ok, because the year is never sent to the server.
        favorite: _cachedRatingFavoriteStatus.favorite,
      );
      _ratingFavoriteStreamController.add(_cachedRatingFavoriteStatus);
    });
  }

  /// favorites a song if not favorited, or unfavorites a song if favorited.
  AsyncResult<Unit> toggleFavorite(String songID) async {
    // early exit if not logged in.
    if (_getStoredAsi().isEmpty) return Failure(NotLoggedInException('Must be logged in to favorite/unfavorite songs'));
    // early exit if the request has already been sent once
    if (_lastSubmittedFavoriteSongID == songID && _lastSubmittedFavoriteState == _cachedRatingFavoriteStatus.favorite) return Success(unit);

    _lastSubmittedFavoriteSongID = songID;
    _lastSubmittedFavoriteState = !_cachedRatingFavoriteStatus.favorite; // ! needed because its going to be toggled later in the function.

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<Unit> result;
    try {
      if (!_cachedRatingFavoriteStatus.favorite) { // add favorite if not favorited.
        result = await _apiClient.addFavorite(_getStoredAsi(), songID);
      } else { // remove favorite if favorited.
        result = await _apiClient.removeFavorite(_getStoredAsi(), songID);
      }
    } on Exception catch(e) {
      result = Failure(e);
    }

    // emit the updated status to the stream
    return result.onSuccess((_) {
      _cachedRatingFavoriteStatus = RatingFavoriteStatus(
        rating: _cachedRatingFavoriteStatus.rating, 
        year: _cachedRatingFavoriteStatus.year,
        favorite: !_cachedRatingFavoriteStatus.favorite, // toggle favorite state
      );
      _ratingFavoriteStreamController.add(_cachedRatingFavoriteStatus);
    });
  }
  
}