import 'package:gr_miniplayer/data/repository/audio_player.dart';

class VolumeControlModel {
  VolumeControlModel({required AudioPlayer audioPlayer}) :
    _player = audioPlayer
    {
      volumeStream = _player.volumeStream;
    }

  final AudioPlayer _player;

  late final Stream<double> volumeStream;

  set volume(double value) => _player.volume = value;
}