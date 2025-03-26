import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:stream_transform/stream_transform.dart';

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
    stateInfoStream = _infoRepo.infoStream.combineLatest(_player.playerStateStream, (info, playerState) =>
      PlayerInfoState(playing: playerState.playing, processingState: playerState.processingState, songInfo: info)
    ).asBroadcastStream();

    if (kDebugMode) { // im pretty sure log() is a no-op in release, but it would still create an unnecessary listener.
      //_infoRepo.infoStream.listen((info) => log('SongInfo: {title: ${info.title}, ...}', name: 'Player State Coordinator'));
      //_player.playerStateStream.listen((state) => log('PlayerState: {playing: ${state.playing}, processingState: ${state.processingState}}', name: 'Player State Coordinator'));
      _loggerSub = stateInfoStream.listen(
        (event) => log('PlayerInfoState: {playing: ${event.playing}}, processingState: ${event.processingState.name}, songInfo: {title: ${event.songInfo.title}}, ...}', name: 'Player State Coordinator')
      );
    } else {
      _loggerSub = null;
    }
  }

  final AudioPlayer _player;
  final SongInfoRepo _infoRepo;

  late final Stream<PlayerInfoState> stateInfoStream;
  late final StreamSubscription<PlayerInfoState>? _loggerSub;

  Future<void> dispose() async => await _loggerSub?.cancel();
}