import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:result_dart/result_dart.dart';

class LoginPageModel extends ChangeNotifier {
  LoginPageModel({required UserResources userResources}) :
    _userResources = userResources;

  final UserResources _userResources;
  
  /// did something go wrong?
  String? error;

  /// closes the login page
  void close() {
    error = null;
    _userResources.needsLoginPage = false;
  }

  Future<void> login(String username, String password) async {
    await _userResources.login(username, password)
      .onSuccess((_) => close()) // close page on successful login
      .onFailure((e) { // otherwise display the error
        error = e.toString();//.replaceAll(RegExp(r'(Exception: )|(unsuccessful: )'), '');
        notifyListeners();
      });
  }
}