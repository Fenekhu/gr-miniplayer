import 'package:gr_miniplayer/data/repository/audio_player.dart';

/// wraps access to the player's volume data.
class VolumeControlModel {
  VolumeControlModel({required AudioPlayer audioPlayer}) :
    _player = audioPlayer;

  final AudioPlayer _player;

  Stream<double> get volumeStream => _player.volumeStream;

  set volume(double value) => _player.volume = value;
}