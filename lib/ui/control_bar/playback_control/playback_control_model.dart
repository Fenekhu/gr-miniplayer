import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

/// wraps state and functionality of the play/stop button
class PlaybackControlModel {
  PlaybackControlModel({required AudioPlayer audioPlayer}) : 
    _player = audioPlayer;

  final AudioPlayer _player;

  bool get playing => _player.playing;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> play() => _player.play();

  Future<void> stop() => _player.pauseOrStop();
}