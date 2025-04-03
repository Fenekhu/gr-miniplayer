import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/song_history.dart';
import 'package:gr_miniplayer/domain/history_track.dart';

class HistoryModel {
  HistoryModel({required SongHistory history}):
    _history = history;

  final SongHistory _history;
  Listenable get listenable => _history; // Hides implementation details from the view.

  UnmodifiableListView<HistoryTrack> get list => _history.list;
}