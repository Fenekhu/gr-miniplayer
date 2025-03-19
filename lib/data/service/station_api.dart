import 'dart:convert';
import 'dart:io';

import 'package:result_dart/result_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;

Map<String, dynamic> _unwrapJson(String data) {
  final json = jsonDecode(data);
  if (json is List<dynamic>) {
    return json.first as Map<String, dynamic>;
  }
  return json as Map<String, dynamic>;
}

class LoginResponse {
  final String result;
  final String userID;
  final String username;
  final String asi;
  final String apiKey;

  const LoginResponse({required this.result, required this.userID, required this.username, required this.asi, required this.apiKey});
}

class RatingGetResponse {
  final String result;
  final int? rating;
  final int? year;
  final bool favorite;

  const RatingGetResponse({required this.result, required this.rating, required this.year, required this.favorite});
}

class StationApiClient {
  StationApiClient(): _client = http.IOClient(HttpClient()..userAgent = app_info.userAgent);

  final http.Client _client;

  void dispose() => _client.close();

  /// Sends a login request
  AsyncResult<LoginResponse> login(String username, String password) async {
    // send login request
    final response = await _client.post(
      Uri.parse('https://gensokyoradio.net/api/login/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'user': username,
        'pass': password,
      },
    );

    // process response
    if (response.statusCode == 200) {
      final body = _unwrapJson(response.body);
      // check the result
      final result = body['RESULT'] as String?;
      if (result?.toLowerCase() == 'success') {
        // ensure that the result is actually valid
        final asi = body['APPSESSIONID'];
        if (asi == null) {
          return Failure(Exception('response did not contain an ASI'));
        } else { // if it is, construct an API response.
          return Success(LoginResponse(
            result: result!, 
            userID: body['USERID'], 
            username: body['USERNAME'], 
            asi: asi, 
            apiKey: body['API'],
          ));
        }
      } else { // if RESULT was not present or was not SUCCESS
        return Failure(Exception('unsuccessful: ${body['ERROR'] ?? 'unknown error'}'));
      }
    } else {
      return Failure(Exception('unexpected response code: ${response.statusCode}'));
    }
  }

  /// Retrieves the rating, year rated, and favorite status.
  AsyncResult<RatingGetResponse> getRatingAndFavorited(String asi, String songID) async {
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

    // process response
    if (response.statusCode == 200) {
      final body = _unwrapJson(response.body);
      // check the result
      final result = body['RESULT'] as String?;
      if (result?.toLowerCase() == 'success') {
        return Success(RatingGetResponse(
          result: result!,
          rating: int.tryParse((body['RATING'] ?? '').toString()),
          year: int.tryParse((body['YEAR'] ?? '').toString()),
          favorite: bool.parse(body['FAVORITE'].toString(), caseSensitive: false),
        ));
      } else {
        return Failure(Exception('unsuccessful: $result'));
      }
    } else {
      return Failure(Exception('unexpected response code: ${response.statusCode}'));
    }
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

    // process response
    if (response.statusCode == 200) {
      final body = _unwrapJson(response.body);
      // check the result
      final result = body['RESULT'] as String?;
      if (result?.toLowerCase() == 'success') {
        return Success(unit);
      } else {
        return Failure(Exception('unsuccessful: $result'));
      }
    } else {
      return Failure(Exception('unexpected response code: ${response.statusCode}'));
    }
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

    // process response
    if (response.statusCode == 200) {
      final body = _unwrapJson(response.body);
      // check the result
      final result = body['RESULT'] as String?;
      if (result?.toLowerCase() == 'success') {
        return Success(unit);
      } else {
        return Failure(Exception('unsuccessful: $result'));
      }
    } else {
      return Failure(Exception('unexpected response code: ${response.statusCode}'));
    }
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

    // process response
    if (response.statusCode == 200) {
      final body = _unwrapJson(response.body);
      // check the result
      final result = body['RESULT'] as String?;
      if (result?.toLowerCase() == 'success') {
        return Success(unit);
      } else {
        return Failure(Exception('unsuccessful: $result'));
      }
    } else {
      return Failure(Exception('unexpected response code: ${response.statusCode}'));
    }
  }
  
}