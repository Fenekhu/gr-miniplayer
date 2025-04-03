import 'dart:convert';
import 'dart:io';

import 'package:gr_miniplayer/domain/history_track.dart';
import 'package:gr_miniplayer/util/exceptions.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/json_util.dart' as json_util;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:result_dart/result_dart.dart';

class LoginResponse {
  final String userID;
  final String username;
  final String asi;
  final String apiKey;

  const LoginResponse({required this.userID, required this.username, required this.asi, required this.apiKey});
}

class RatingResponse {
  final int? rating; // null if not yet rated
  final int? year; // null if not yet rated
  final bool favorite;

  const RatingResponse({required this.rating, required this.year, required this.favorite});
}

class StationApiClient {
  StationApiClient(): _client = http.IOClient(HttpClient()..userAgent = app_info.userAgent);

  /// custom http client with custom userAgent.
  final http.Client _client;

  /// clean up http client
  void dispose() => _client.close();

  // most API endpoints responses look like {'RESULT':'SUCCESS', ...}
  /// Processes a response, checking that the RESULT field was SUCCESS, returning a failure if not.
  /// Returns the response body if successful.
  Result<Map<String, dynamic>> _checkGenericResponse(http.Response response, {int expectedCode = 200}) {
    // process response
    if (response.statusCode == expectedCode) {
      final body = json_util.unwrapJson(response.body);
      // check the result
      final result = body['RESULT']?.toString();
      if (result?.toLowerCase() == 'success') {
        return Success(body);
      } else {
        return Failure(BadServerResultException.fromBody(body));
      }
    } else {
      return Failure(BadResponseCodeException(response));
    }
  }

  /// Sends a login request
  AsyncResult<LoginResponse> login(String username, String password) async {
    // send login request
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/login/'),
      headers: { 
        'Content-Type': 'application/x-www-form-urlencoded', // technically this is not necessary. Looking at the client.post impl, passing a map type as body forces this kind of encoding anyway.
      },
      body: {
        'user': username,
        'pass': password,
      },
    );

    // check if the server returned a successful response,
    // then further process the response body into a Login response if so.
    // flatMap is used when the function that transforms a success returns a Result type itself, and unwraps that result.
    return _checkGenericResponse(response).flatMap((body) {
      final asi = body['APPSESSIONID']?.toString();
      if (asi == null) {
        return Failure(InvalidResponseException('response did not contain an ASI', body));
      } else { // if it is, construct an API response.
        return Success(LoginResponse(
          userID: body['USERID']?.toString() ?? '', // may be sent as a string or an int. int is not assignable to String. 
          username: body['USERNAME']?.toString() ?? '', 
          asi: asi, 
          apiKey: body['API']?.toString() ?? '',
        ));
      }
    });
  }

  /// Retrieves the rating, year rated, and favorite status.
  AsyncResult<RatingResponse> getRatingAndFavorited(String asi, String songID) async {
    // send request
    // note: this only differs from submitRating request by the presence of the rating parameter in the body.
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/station/rating/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'asi': asi,
        'song_id': songID,
      },
    );

    // check if the server returned a successful response,
    // then further process the response body into a Rating response if so.
    return _checkGenericResponse(response).map((body) => 
      RatingResponse(
        rating: json_util.tryToInt(body['RATING']),
        year: json_util.tryToInt(body['YEAR']),
        favorite: json_util.tryToBool(body['FAVORITE']) ?? false,
      )
    );
  }

  /// Submits a song rating
  AsyncResult<Unit> submitRating(String asi, String songID, int rating) async {
    // send request
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/station/rating/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'asi': asi,
        'song_id': songID,
        'rating': rating.toString(),
      },
    );

    // check if the server returned a successful response, 
    // then discard the "empty" body.
    return _checkGenericResponse(response).map((_) => unit);
  }

  /// Favorites a song
  AsyncResult<Unit> addFavorite(String asi, String songID) async {
    // send request
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/user/favorite/add/song/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'asi': asi,
        'q': songID,
      },
    );

    // check if the server returned a successful response, 
    // then discard the "empty" body.
    return _checkGenericResponse(response).map((_) => unit);
  }

  /// Unfavorites a song
  AsyncResult<Unit> removeFavorite(String asi, String songID) async {
    // send request
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/user/favorite/remove/song/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'asi': asi,
        'q': songID,
      },
    );

    // check if the server returned a successful response, 
    // then discard the "empty" body.
    return _checkGenericResponse(response).map((_) => unit);
  }

  /// Gets the last 25 songs played on the station.
  AsyncResult<Iterable<HistoryTrack>> getHistory() async {
    final response = await _client.get(
      Uri.parse('https://gensokyoradio.net/api/station/history'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      // the API gives the history with the most recent at [0], but I want the most recent at the end of the list to make growing more natural.
      // Then .map() converts each Map<String, dynamic> to a HistoryTrack object.
      return Success(body.reversed.map((track) =>
        HistoryTrack(
          played: json_util.tryToInt(track['PLAYED']) ?? 0, 
          title: track['TITLE']?.toString() ?? '', 
          artist: track['ARTIST']?.toString() ?? '', 
          albumID: track['ALBUMID']?.toString() ?? '', 
          album: track['ALBUM']?.toString() ?? '', 
          albumArt: track['ALBUMART']?.toString() ?? '', 
          circle: track['CIRCLE']?.toString() ?? '', 
          track: json_util.tryToInt(track['TRACK']) ?? 0
        )
      ));
    } else {
      return Failure(BadResponseCodeException(response));
    }

  }
  
}