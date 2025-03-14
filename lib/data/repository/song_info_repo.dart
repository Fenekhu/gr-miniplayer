import 'package:gr_miniplayer/data/service/hidden_art_list.dart';
import 'package:gr_miniplayer/data/service/info_websocket.dart';
import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:result_dart/result_dart.dart';

// the api is not consistent with types. For example, sometimes you may get year: 2019 or year: '2019'.
// Calling .toString on either will convert it to '2019', which can then be parsed.
// Extra considerations have been made for null or invalid values.
int? _tryToInt(dynamic v) {
  if (v == null) return null;
  return int.tryParse(v.toString());
}

class SongInfoRepo {
  SongInfoRepo({required InfoWebsocket infoWebsocket, required HiddenArtList hiddenArtList}) :
    _websocket = infoWebsocket, _hiddenArt = hiddenArtList {
    infoStream = infoWebsocket.infoStream.asyncMap(_processSongInfo).asBroadcastStream();
  }

  final InfoWebsocket _websocket;
  final HiddenArtList _hiddenArt;
  late final Stream<SongInfo> infoStream;

  Future<SongInfo> _processSongInfo(Map<String, dynamic> data) async {
    final String? albumID = data['albumid'  ]?.toString();
    return SongInfo(
         songID: data['songid'   ]?.toString() ?? '0', 
          title: data['title'    ]?.toString() ?? '(untitled)', 
         artist: data['artist'   ]?.toString() ?? '(unknown artist)', 
        albumID: albumID                       ?? '0', 
          album: data['album'    ]?.toString() ?? '(unknown album)', 
         circle: data['circle'   ]?.toString() ?? '(unknown circle)', 
       albumArt: data['albumart' ]?.toString() ?? '', 
           year: _tryToInt(data['year'      ]) ?? 0, 
       duration: _tryToInt(data['duration'  ]) ?? 0, 
         played: _tryToInt(data['played'    ]) ?? 0, 
      remaining: _tryToInt(data['remaining' ]) ?? 0,
        hideArt: albumID != null && (await _hiddenArt.list).contains(albumID), // will never hiding songs with no albumID be ok?
    );
  }

  /// Connects to the websocket. 
  /// If an error occurs, attempts reconnection after [retryDelay].
  /// If [retryDelay] is null, does not attempt to reconnect.
  AsyncResult<Unit> connect({Duration? retryDelay = const Duration(minutes: 2)}) async {
    return await _websocket.connect(retryDelay);
  }
}