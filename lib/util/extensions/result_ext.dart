import 'dart:developer' show log;

import 'package:result_dart/result_dart.dart';

extension MyResultDartExtension<S extends Object, F extends Object> on ResultDart<S, F> {
  /// If this result is a failure, prints it to the log.
  /// Returns this result unmodified.
  ResultDart<S, F> logOnFailure([String name = '']) {
    return onFailure(
      (failure) => log(failure.toString(), name: name, error: failure)
    );
  }
}

extension MyAsyncResultDartExtension<S extends Object, F extends Object> on AsyncResultDart<S, F> {
  /// If this result resolves to a failure, prints it to the log.
  /// Returns this result unmodified.
  AsyncResultDart<S, F> logOnFailure([String name = '']) {
    return onFailure(
      (failure) => log(failure.toString(), name: name, error: failure)
    );
  }
}