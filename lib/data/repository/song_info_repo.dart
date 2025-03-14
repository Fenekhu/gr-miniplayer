import 'package:gr_miniplayer/data/service/hidden_art_list.dart';
import 'package:gr_miniplayer/data/service/info_websocket.dart';
import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:result_dart/result_dart.dart';

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
          title: data['title'    ] ?? '(untitled)', 
         artist: data['artist'   ] ?? '(unknown artist)', 
        albumID: albumID           ?? '0', 
          album: data['album'    ] ?? '(unknown album)', 
         circle: data['circle'   ] ?? '(unknown circle)', 
           year: data['year'     ] ?? 0, 
       albumArt: data['albumart' ] ?? '', 
       duration: data['duration' ] ?? 0, 
         played: data['played'   ] ?? 0, 
      remaining: data['remaining'] ?? 0,
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