import 'dart:ui';

import 'package:gr_miniplayer/data/service/hidden_art_list.dart';
import 'package:gr_miniplayer/data/service/info_websocket.dart';
import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:gr_miniplayer/util/lib/json_util.dart' as json_util;
import 'package:result_dart/result_dart.dart';

// turn seconds into mm:ss
String _formatSeconds(int seconds) {
  final minutes = (seconds ~/ 60).toString();
  final seconds_ = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds_';
}

/// Provides a stream of SongInfo from the websocket, as well as the most recent SongInfo received.
class SongInfoRepo {
  SongInfoRepo({required InfoWebsocket infoWebsocket, required HiddenArtList hiddenArtList}) :
    _websocket = infoWebsocket, 
    _hiddenArt = hiddenArtList {
      // set up processing for the underlying websocket output into SongInfo objects.
      infoStream = infoWebsocket.infoStream.asyncMap(_processSongInfo).asBroadcastStream();
      // create a stream that emits a new progress status every second.
      progressStream = Stream<ProgressStatus>.periodic(
        Duration(seconds: 1),
        (_) {
          final duration = latestInfo?.duration ?? 0;
          final ret = ProgressStatus(
            elapsed: _formatSeconds(_played), 
            total: duration <= 0? '--:--' : _formatSeconds(duration), 
            value: duration <= 0? 0.5 : clampDouble(_played / duration, 0, 1),
          );
          _played++;
          return ret;
        }
      );
    }

  final InfoWebsocket _websocket;
  final HiddenArtList _hiddenArt;

  /// stream of SongInfo as it comes from the websocket.
  late final Stream<SongInfo> infoStream;
  /// periodic stream of song progress information (elapsed, duration, etc)
  late final Stream<ProgressStatus> progressStream;

  SongInfo? _latestInfo;
  SongInfo? get latestInfo => _latestInfo; // may be null if no data has been received yet.

  int _played = 0;
  int get played => _played;

  /// converts a json map into a SongInfo object.
  Future<SongInfo> _processSongInfo(Map<String, dynamic> data) async {
    // note the usage of .toString()
    // this is because, for example, 'songid' may be sent as an int or a string,
    // and if sent as an int, cannot be assigned to String songID.
    // in otherwords, it a guarantee of type safety for a dynamic type.
    final String? albumID = data['albumid'  ]?.toString();
    _latestInfo = SongInfo(
         songID: data['songid'   ]?.toString()          ?? '0', 
          title: data['title'    ]?.toString()          ?? '(untitled)', 
         artist: data['artist'   ]?.toString()          ?? '(unknown artist)', 
        albumID: albumID                                ?? '0', 
          album: data['album'    ]?.toString()          ?? '(unknown album)', 
         circle: data['circle'   ]?.toString()          ?? '(unknown circle)', 
       albumArt: data['albumart' ]?.toString()          ?? '', 
           year: json_util.tryToInt(data['year'      ]) ?? 0, 
       duration: json_util.tryToInt(data['duration'  ]) ?? 0, 
         played: json_util.tryToInt(data['played'    ]) ?? 0, 
      remaining: json_util.tryToInt(data['remaining' ]) ?? 0,
        hideArt: albumID != null && (await _hiddenArt.list).contains(albumID), // will never hiding songs with no albumID be ok?
    );
    _played = _latestInfo?.played ?? 0; // reset the elapsed time counter
    return _latestInfo!;
  }

  /// Connects to the websocket. 
  /// If an error occurs, attempts reconnection after [retryDelay].
  /// If [retryDelay] is null, does not attempt to reconnect.
  AsyncResult<Unit> connect({Duration? retryDelay = const Duration(minutes: 2)}) async {
    return await _websocket.connect(retryDelay);
  }
}