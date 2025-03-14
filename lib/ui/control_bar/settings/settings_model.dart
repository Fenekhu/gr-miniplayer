import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';

class SettingsMenuModel {
  SettingsMenuModel({required AudioPlayer audioPlayer}) :
    _player = audioPlayer;

  final AudioPlayer _player;

  StreamEndpoint? get endpoint => _player.endpoint;

  set endpoint(StreamEndpoint? endpoint) {
    _player.endpoint = endpoint;
    if (endpoint != null) app_settings.streamEndpoint = endpoint;
  }
}