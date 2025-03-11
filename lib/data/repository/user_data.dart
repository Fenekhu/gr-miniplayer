import 'package:gr_miniplayer/util/lib/shared_prefs.dart';
import 'package:gr_miniplayer/data/service/station_api.dart';
import 'package:result_dart/result_dart.dart';

String _getStoredAsi() => sharedPrefs.containsKey('user.asi') ? sharedPrefs.getString('user.asi') ?? '' : '';
void _setStoredAsi(String asi) => sharedPrefs.setString('user.asi', asi);

String _getStoredApiKey() => sharedPrefs.containsKey('user.apiKey') ? sharedPrefs.getString('user.apiKey') ?? '' : '';
void _setStoredApiKey(String apiKey) => sharedPrefs.setString('user.apiKey', apiKey);

class UserSessionData {
  final String userID;
  final String username;
  final String asi;
  final String apiKey;

  const UserSessionData({required this.userID, required this.username, required this.asi, required this.apiKey});
  const UserSessionData.empty() : this(userID: '', username: '', asi: '', apiKey: '');
  UserSessionData.fromStorage() : this(userID: '', username: '', asi: _getStoredAsi(), apiKey: _getStoredApiKey());
}

class RatingFavoriteStatus {
  final int? rating;
  final int? year;
  final bool favorite;

  const RatingFavoriteStatus({required this.rating, required this.year, required this.favorite});
  const RatingFavoriteStatus.empty() : this(rating: null, year: null, favorite: false);
}

class UserResources {

  UserResources({required StationApiClient apiClient})
    : _apiClient = apiClient,
      userSessionData = UserSessionData.fromStorage(),
      ratingFavoriteStatus = RatingFavoriteStatus.empty();

  final StationApiClient _apiClient;

  UserSessionData userSessionData;
  RatingFavoriteStatus ratingFavoriteStatus;

  /// Logs in with the given credentials.
  AsyncResult<UserSessionData> login(String username, String password) async {
    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<LoginResponse> result;
    try {
      result = await _apiClient.login(username, password);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the successful result, transforming it into a UserSessionData object
    // and storing the asi and api key for persistent sessions.
    return result.map((lr) {
      _setStoredAsi(lr.asi);
      _setStoredApiKey(lr.apiKey);
      userSessionData = UserSessionData(
        userID: lr.userID, 
        username: lr.username, 
        asi: lr.asi, 
        apiKey: lr.apiKey,
      );
      return userSessionData;
    });
  }

  /// Logs out, clearing all user information.
  void logout() {
    _setStoredAsi('');
    _setStoredApiKey('');
    userSessionData = UserSessionData(
      userID: '', 
      username: '', 
      asi: '', 
      apiKey: '',
    );
  }

  /// Gets the current rating information and favorite status of the song.
  /// Note that the server requires songID match the currently playing song.
  AsyncResult<RatingFavoriteStatus> getRatingAndFavoriteStatus(String songID) async {
    // early exit if not logged in.
    if (userSessionData.asi.isEmpty) {
      return Success(RatingFavoriteStatus(rating: null, year: null, favorite: false));
    }

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<RatingGetResponse> result;
    try {
      result = await _apiClient.getRatingAndFavorited(userSessionData.asi, songID);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the succesful result, transforming it into a RatingFavoriteStatus object.
    return result.map((resp) {
      ratingFavoriteStatus = RatingFavoriteStatus(
        rating: resp.rating, 
        year: resp.year, 
        favorite: resp.favorite,
      );
      return ratingFavoriteStatus;
    });
  }

  AsyncResult<RatingFavoriteStatus> submitRating(String songID, int rating) async {
    // early exit if rating is an invalid value somehow
    if (rating < 1 || rating > 5) return Failure(Exception('rating $rating outside valid range'));
    // early exit if not logged in.
    if (userSessionData.asi.isEmpty) return Failure(Exception('Must be logged in to rate songs'));

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<Unit> result;
    try {
      result = await _apiClient.submitRating(userSessionData.asi, songID, rating);
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the succesful result, transforming it into a RatingFavoriteStatus object.
    return result.map((resp) {
      ratingFavoriteStatus = RatingFavoriteStatus(
        rating: rating, 
        year: DateTime.now().year, // note that the user may modify the date on their machine. This is ok, because the year is never sent to the server.
        favorite: ratingFavoriteStatus.favorite,
      );
      return ratingFavoriteStatus;
    });
  }

  AsyncResult<RatingFavoriteStatus> toggleFavorite(String songID) async {
    // early exit if not logged in.
    if (userSessionData.asi.isEmpty) return Failure(Exception('Must be logged in to favorite/unfavorite songs'));

    // As the station's API is not well documented and is subject to change,
    // it's possible that exceptions are thrown while trying to parse the response.
    // In that case, forward that exception as the Failure.
    Result<Unit> result;
    try {
      if (!ratingFavoriteStatus.favorite) { // add favorite if not favorited.
        result = await _apiClient.addFavorite(userSessionData.asi, songID);
      } else { // remove favorite if favorited.
        result = await _apiClient.removeFavorite(userSessionData.asi, songID);
      }
    } on Exception catch(e) {
      result = Failure(e);
    }

    // process the succesful result, transforming it into a RatingFavoriteStatus object.
    return result.map((resp) {
      ratingFavoriteStatus = RatingFavoriteStatus(
        rating: ratingFavoriteStatus.rating, 
        year: ratingFavoriteStatus.year,
        favorite: !ratingFavoriteStatus.favorite, // toggle favorite state
      );
      return ratingFavoriteStatus;
    });
  }
  
}