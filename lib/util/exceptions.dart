/* Custom exception types to make handling different exceptions easier.
 * These mimic the Dart `Error` class heirarchy, but according to the Dart documentation:
 *   Exceptions are expected and meant to be caught.
 *   Errors signal bad programming and should crash as a sign to the developer to fix something.
 * While this is a sensible paradigm, it doesn't always work well with ResultDart, which handles Exceptions.
 * For example, if something goes wrong due to bad data ultimately passed on from the websocket,
 * invalid data from beyond our control should never cause a crash.
 * That bad data should be detected as an exception and put in a result,
 * even if its bad for a reason that aligns much closer to an Error subclass.
 */

import 'package:http/http.dart';

/// Indicates that a non-argument variable (member, global, etc) has an invalid value that prevents further execution.
class StateException implements Exception {
  const StateException([this.value, this.variable, this.type = 'StateException']);

  final dynamic value;
  final String? variable;
  final String type;

  @override
  String toString() {
    if (variable == null) return type;
    return '$type: $variable is $value';
  }
}

/// Indicates that the latest song info is missing, or is missing a valid song id
class MissingSongIDException extends StateException {
  const MissingSongIDException([super.value, super.variable = 'song id', super.type = 'MissingSongIDException']);
}

/// Indicates that the operation is not supported because the user is not logged in.
class NotLoggedInException implements Exception {
  const NotLoggedInException([this.message]);

  final String? message;

  @override
  String toString() {
    if (message == null) return 'Not Logged In';
    return 'Not Logged In: $message';
  }
}





/// Base class for exceptions involving server responses.
abstract class BadResponseException implements Exception {
  const BadResponseException();
}

/// Indicates that the server returned an unexpected or otherwise not good response code.
class BadResponseCodeException extends BadResponseException {
  const BadResponseCodeException(this.response);

  final Response response;

  @override
  String toString() {
    final String? request = response.request?.toString();
    final int code = response.statusCode;
    final String? codePhrase = response.reasonPhrase;
    final ret = StringBuffer('Bad Server Response: $code');
    if (codePhrase != null) ret.write('($codePhrase)');
    if (request != null) ret.write(', request: $request');
    return ret.toString();
  }
}

/// Indicates that the server intentionally returned a negative response to a request.
class BadServerResultException implements Exception {
  const BadServerResultException([this.message]);
  BadServerResultException.fromBody(Map<String, dynamic> body) :
    message = body['ERROR'];

  final dynamic message;

  @override
  String toString() {
    return 'Server Error: $message';
  }
}

/// Indicates that the response from the server was in some way invalid, such as missing crucial data.
class InvalidResponseException implements Exception {
  const InvalidResponseException([this.message, this.body]);

  final dynamic message;
  final dynamic body;

  @override
  String toString() {
    if (body == null) return 'InvalidResponseException: $message';
    return 'InvalidResponseException: $message | Response: $body';
  }
}