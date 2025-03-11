import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/hidden_art_manager.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';

class ArtDisplayModel extends ChangeNotifier {
  static const BoxFit _imageFit = BoxFit.contain;
  
  ArtDisplayModel({
    required HiddenArtManager hiddenArtManager,
    required SongInfoRepo songInfoRepo,
  }): _hiddenArtManager = hiddenArtManager,
      _songInfoRepo = songInfoRepo,
      _placeholderArt = Image.asset('assets/images/placeholder-art.png', fit: _imageFit)
      {
        _songInfoRepo.infoStream.listen(_onSongInfo);
        _albumArt = _placeholderArt;
      }

  final HiddenArtManager _hiddenArtManager;
  final SongInfoRepo _songInfoRepo;
  final Image _placeholderArt;

  String _albumID = '0';
  String _albumArtSrc = '';
  bool _hide = false;
  late Image _albumArt;

  void _onSongInfo(SongInfo info) {
    _albumID = info.albumID;
    _albumArtSrc = info.albumArt;
    _hide = info.hideArt;

    _albumArt = _albumArtSrc.isEmpty? 
      _placeholderArt :
      Image.network(
        _albumArtSrc,
        fit: _imageFit,
        errorBuilder: (context, error, stackTrace) => _placeholderArt,
      );

    updateArt();
  }

  bool get hide => _hide;
  Image get albumArt => _albumArt;

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