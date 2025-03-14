import 'dart:developer';

import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:stream_transform/stream_transform.dart';

class PlayerState {
  final bool playing;
  final ja.ProcessingState processingState;
  final SongInfo songInfo;

  const PlayerState({required this.playing, required this.processingState, required this.songInfo});
}

class PlayerStateCoordinator {
  PlayerStateCoordinator({
    required AudioPlayer audioPlayer,
    required SongInfoRepo songInfoRepo,
  }) :
    _player = audioPlayer,
    _infoRepo = songInfoRepo
  {
    stateInfoStream = _infoRepo.infoStream.combineLatest(_player.playerStateStream, (info, playerState) => 
      PlayerState(playing: playerState.playing, processingState: playerState.processingState, songInfo: info)
    );
    stateInfoStream.listen(_onStateEvent);
  }

  final AudioPlayer _player;
  final SongInfoRepo _infoRepo;

  late final Stream<PlayerState> stateInfoStream;

  void _onStateEvent(PlayerState state) {
    log('{playing: ${state.playing}}, processingState: ${state.processingState.name}, songInfo.title: ${state.songInfo.title}}', name: 'Player State');
  }
}