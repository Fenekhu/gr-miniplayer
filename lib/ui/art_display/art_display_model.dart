import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/art_provider.dart';
import 'package:gr_miniplayer/data/repository/hidden_art_manager.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/song_info.dart';

class ArtDisplayModel extends ChangeNotifier {  
  ArtDisplayModel({
    required HiddenArtManager hiddenArtManager,
    required SongInfoRepo songInfoRepo,
    required ArtProvider artProvider,
  }): _hiddenArtManager = hiddenArtManager,
      _songInfoRepo = songInfoRepo,
      _artProvider = artProvider
      {
        _streamSubscription = _songInfoRepo.infoStream.listen(_onSongInfo);
        _albumID = _songInfoRepo.latestInfo?.albumID ?? _albumID;
        _hide = _songInfoRepo.latestInfo?.hideArt ?? _hide;
        _albumArt = _artProvider.load(_songInfoRepo.latestInfo?.albumArt ?? '');
      }

  final HiddenArtManager _hiddenArtManager;
  final SongInfoRepo _songInfoRepo;
  final ArtProvider _artProvider;

  late final StreamSubscription<SongInfo> _streamSubscription;

  String _albumID = '0';
  bool _hide = false;
  late Image _albumArt;

  bool get hide => _hide;
  Image get albumArt => _albumArt;

  void _onSongInfo(SongInfo info) {
    log('onSongInfo', name: 'Art Display Model');
    _albumID = info.albumID;
    _hide = info.hideArt;
    _albumArt = _artProvider.load(info.albumArt);

    updateArt();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void updateArt() {
    notifyListeners();
  }

  void hideCurrentArt() {
    if (_albumID.isNotEmpty && _albumID != '0') _hiddenArtManager.add(_albumID);
    _hide = true;
    updateArt();
  }

  void unhideCurrentArt() {
    if (_albumID.isNotEmpty && _albumID != '0') _hiddenArtManager.remove(_albumID);
    _hide = false;
    updateArt();
  }

  void toggleAlbumArt() {
    hide? unhideCurrentArt() : hideCurrentArt();
  }
}