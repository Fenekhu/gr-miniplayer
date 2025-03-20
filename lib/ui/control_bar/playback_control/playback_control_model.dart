import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:just_audio/just_audio.dart' as ja;

/// wraps state and functionality of the play/stop button
class PlaybackControlModel {
  PlaybackControlModel({required AudioPlayer audioPlayer}) : 
    _player = audioPlayer;

  final AudioPlayer _player;

  Stream<ja.PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> play() {
    return _player.play();
  }

  Future<void> stop() {
    return _player.pauseOrStop();
  }
}