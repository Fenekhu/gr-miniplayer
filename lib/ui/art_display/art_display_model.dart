import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/art_provider.dart';
import 'package:gr_miniplayer/data/repository/hidden_art_manager.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

/// Wraps functions for getting album art updates and hiding/showing art.
class ArtDisplayModel {  
  ArtDisplayModel({
    required HiddenArtManager hiddenArtManager,
    required SongInfoRepo songInfoRepo,
    required ArtProvider artProvider,
  }): _hiddenArtManager = hiddenArtManager,
      _songInfoRepo = songInfoRepo,
      _artProvider = artProvider;

  final HiddenArtManager _hiddenArtManager;
  final SongInfoRepo _songInfoRepo;
  final ArtProvider _artProvider;


  Stream<SongInfo> get infoStream => _songInfoRepo.infoStream;
  Stream<ArtHidingStatus> get visibilityStream => _hiddenArtManager.artHidingStatusStream;

  Image getAlbumArt(String url) => _artProvider.get(url);

  void toggleAlbumArt(String albumID) {
    if (albumID.isNotEmpty && albumID != '0') _hiddenArtManager.toggle(albumID);
  }
}