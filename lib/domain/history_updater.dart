import 'dart:async';

import 'package:gr_miniplayer/data/repository/song_history.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/history_track.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

class HistoryUpdater {
  HistoryUpdater({required SongInfoRepo infoRepo, required SongHistory history}):
    _infoRepo = infoRepo,
    _history = history {
      _infoStreamSub = _infoRepo.infoStream.listen(
        (info) => _history.add(
          HistoryTrack(
            played: _infoRepo.played,
            title: info.title, 
            artist: info.artist, 
            albumID: info.albumID, 
            album: info.album, 
            albumArt: info.albumArt, 
            circle: info.circle, 
            track: 0 // Song info doesn't contain this, so I probably wont be displaying it either
          )
        ),
      );
    }

  final SongInfoRepo _infoRepo;
  final SongHistory _history;

  late StreamSubscription<SongInfo> _infoStreamSub;

  void dispose() => _infoStreamSub.cancel();
}