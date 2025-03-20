import 'package:gr_miniplayer/data/repository/user_data.dart';

/// Provides access to the 'needLoginPage' state from UserResources.
class ArtOrLoginModel {
  ArtOrLoginModel({required UserResources userResources}) :
    _userResources = userResources;

  final UserResources _userResources;

  Stream<bool> get needsLoginPageStream => _userResources.needsLoginPageStream;
}