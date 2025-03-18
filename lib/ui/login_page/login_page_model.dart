import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';

class LoginPageModel extends ChangeNotifier {
  LoginPageModel({required UserResources userResources}) :
    _userResources = userResources;

  final UserResources _userResources;
  
  String? error;

  void close() {
    _userResources.needsLoginPage = false;
  }

  Future<void> login(String username, String password) async {
    (await _userResources.login(username, password))
      .onSuccess((apiResult) {
        error = null;
        close();
      })
      .onFailure((e) {
        error = e.toString().replaceAll(RegExp(r'(Exception: )|(unsuccessful: )'), '');
        notifyListeners();
      });
  }
}