import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/service/station_api.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/util/extensions/result_ext.dart';
import 'package:result_dart/result_dart.dart';

/// Holds and manages the song history. 
// I decided to go with a ChangeNotifier here instead of the usual stream-based approach,
// because it wouldn't make sense to do Stream<List<HistoryTrack>>, sending the whole list when one thing is added,
// but Stream<HistoryTrack> would require the UI to hold a separate list in its state, which is unneccesary.
// It's best if we can just tell the UI "hey the list changed, go check it."
class SongHistory extends ChangeNotifier {
  SongHistory({required StationApiClient apiClient}):
    _apiClient = apiClient {
      _fetchHistory();
    }

  final StationApiClient _apiClient;

  final List<HistoryTrack> _list = List.empty(growable: true);
  late final list = UnmodifiableListView(_list); // 'late' causes this to be evaluated on first use, which is needed to guarantee _history has been initialized.

  bool justFetched = false;

  Future<void> _fetchHistory() async {
    await _apiClient.getHistory()
      .logOnFailure('Song History')
      .onSuccess(
        (res) {
          _list.clear();
          _list.addAll(res);
          justFetched = true;
          notifyListeners();
        },
      );
  }

  bool _isProbablyDuplicate(HistoryTrack a, HistoryTrack b) {
    return 
      a.title == b.title && 
      a.album == b.album && 
      a.circle == b.circle;
  }

  void add(HistoryTrack track) {
    // the history fetch contains the currently playing track, which will also get sent by the websocket.
    // this early exit should hopefully prevent it being in there twice for that reason.
    if (justFetched && _isProbablyDuplicate(track, _list.last)) return;
    _list.add(track);
    notifyListeners();
  }
}