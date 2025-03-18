import 'dart:async';

import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';

class SettingsMenuModel {
  SettingsMenuModel({required AudioPlayer audioPlayer, required UserResources userResources}) :
    _player = audioPlayer,
    _userResources = userResources;

  final AudioPlayer _player;
  final UserResources _userResources;

  StreamEndpoint? get endpoint => _player.endpoint;
  Stream<UserSessionData> get userDataStream => _userResources.userDataStream;

  set endpoint(StreamEndpoint? endpoint) {
    _player.endpoint = endpoint;
    if (endpoint != null) app_settings.streamEndpoint = endpoint;
  }

  void login() {
    _userResources.needsLoginPage = true;
  }

  void logout() {
    _userResources.logout();
  }
}