import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/art_cache.dart';
import 'package:gr_miniplayer/data/repository/song_history.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

class HistoryModel {
  HistoryModel({required SongHistory history, required ArtCache artCache}):
    _history = history,
    _artCache = artCache;

  final SongHistory _history;
  final ArtCache _artCache;

  Listenable get listenable => _history; // Hides implementation details from the view.

  UnmodifiableListView<HistoryTrack> get list => _history.list;
  
  Widget getThumbnail(String url) => _artCache.getImageWidget(url);
}