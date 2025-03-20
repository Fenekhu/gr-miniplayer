import 'dart:developer';

import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:stream_transform/stream_transform.dart';

/// Represents the current song and player state
class PlayerInfoState {
  final bool playing;
  final ja.ProcessingState processingState;
  final SongInfo songInfo;

  const PlayerInfoState({required this.playing, required this.processingState, required this.songInfo});
}

/// Bridges the player and song info for use with services (discord, media transport)
class PlayerStateCoordinator {
  PlayerStateCoordinator({
    required AudioPlayer audioPlayer,
    required SongInfoRepo songInfoRepo,
  }) :
    _player = audioPlayer,
    _infoRepo = songInfoRepo
  {
    // create a new stream that combines the playerStateStream and songInfoStream into one.
    stateInfoStream = _infoRepo.infoStream.combineLatest(_player.playerStateStream, (info, playerState) {
      log('{playing: ${playerState.playing}}, processingState: ${playerState.processingState.name}, songInfo.title: ${info.title}}', name: 'Player State');
      return PlayerInfoState(playing: playerState.playing, processingState: playerState.processingState, songInfo: info);
    }).asBroadcastStream();
  }

  final AudioPlayer _player;
  final SongInfoRepo _infoRepo;

  late final Stream<PlayerInfoState> stateInfoStream;
}