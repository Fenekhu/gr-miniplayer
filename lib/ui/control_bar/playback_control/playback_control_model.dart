import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:just_audio/just_audio.dart' as ja;

class PlaybackControlModel {
  PlaybackControlModel({
    required AudioPlayer audioPlayer,
  }) : 
    _player = audioPlayer
    {
      playerStateStream = _player.playerStateStream;
    }

  final AudioPlayer _player;

  late final Stream<ja.PlayerState> playerStateStream;

  Future<void> play() {
    return _player.play();
  }

  Future<void> stop() {
    return _player.pauseOrStop();
  }
}