import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/json_util.dart' as json_util;
import 'package:result_dart/result_dart.dart';

/// Websocket handler for the live song info
class InfoWebsocket {
  InfoWebsocket()
    : _httpClient = HttpClient()..userAgent = app_info.userAgent, // create an http client with a custom userAgent
      _outStreamController = StreamController<Map<String, dynamic>>(); // not a broadcast stream because only SongInfoRepo will connect to it.

  /// the client that will be used to connect to the websocket.
  final HttpClient _httpClient; 
  /// represents an input and output stream from the actual socket.
  WebSocket? _webSocket; 
  /// used by the station's manual ping/pong system
  int _socketID = 0; 
  /// emits only song information messages from the websocket.
  final StreamController<Map<String, dynamic>> _outStreamController;

  Duration? _retryDelay; // if stream connection issue
  /// live song info stream
  Stream<Map<String, dynamic>> get infoStream => _outStreamController.stream;

  /// cleans up client and stream resources.
  void dispose() {
    _webSocket?.close(WebSocketStatus.goingAway);
    _httpClient.close();
    _outStreamController.close();
  }

  /// connects to the websocket. Will not complete until successful connection or complete failure (no retry)
  AsyncResult<Unit> connect(Duration? retryDelay) async {
    _retryDelay = retryDelay;
    _webSocket?.close(WebSocketStatus.normalClosure, 'Reconnecting');

    do { // attemt to connect at least one. Repeat if retry delay is not null.
      developer.log('Connecting to websocket', time: DateTime.now(), name:'Info Websocket');
      try {
        _webSocket = await WebSocket.connect(
          'wss://gensokyoradio.net/wss',
          customClient: _httpClient,
        );
        developer.log('Websocket connected', time: DateTime.now(), name:'Info Websocket');
        break; // successfully connected, leave retry loop.
      } catch(e, trace) { // if something went wrong
        developer.log('Connection Error', time: DateTime.now(), name:'Info Websocket', error: e, stackTrace: trace);
        if (_retryDelay == null) { // exit function if retrying is disabled
          return Failure(Exception('Could not connect to websocket'));
        } else { // otherwise leave a message in the log and wait until its time to retry.
          developer.log('Retrying in ${_retryDelay!.inSeconds} seconds', time: DateTime.now(), name:'Info Websocket');
          await Future.delayed(_retryDelay!);
        }
      }
    } while (_retryDelay != null);

    // listens to incoming events from the websocket.
    _webSocket?.listen(_handleData, onError: _handleError, cancelOnError: true);

    // initiates communications with the websocket, letting the server know we want live info.
    _sendJson({'message': 'grInitialConnection'});

    return Success(unit);
  }

  void _sendJson(Map<String, dynamic> msg) {
    final event = jsonEncode(msg);
    developer.log('Sending Message: $event', time: DateTime.now(), name: 'Info Websocket');
    _webSocket?.add(event);
  }

  void _handleError(Object error, StackTrace trace) {
    developer.log('Stream Error', time: DateTime.now(), name:'Info Websocket', error: error, stackTrace: trace);
    // if there is a websocket error (connection dropped, etc) clear the websocket to prevent attempted further communication.
    _webSocket = null;
    if (_retryDelay != null) { // retry connection if enabled.
      developer.log('Reconnecting in ${_retryDelay!.inSeconds} seconds', time: DateTime.now(), name:'Info Websocket');
      Future.delayed(_retryDelay!, () => connect(_retryDelay));
    }
  }

  /// handles a message from the websocket.
  void _handleData(dynamic event) {
    final msg = jsonDecode(event) as Map<String, dynamic>;

    // convenience method for testing a key is present && the value is something specific.
    bool tryEq(String key, dynamic value) {
      return msg.containsKey(key) && msg[key] == value;
    }

    if (tryEq('message', 'welcome')) { // handle welcome message
      developer.log('Received Message: $event', time: DateTime.now(), name: 'Info Websocket');
      _socketID = json_util.tryToInt(msg['id'])!; // the welcome message contains an ID that needs to be sent back with each pong
    } else if (tryEq('message', 'ping')) { // if ping, respond with pong
      // no log incomming message here to allow VSCode to group identical messages (just the pongs are enough)
      _sendJson({'message': 'pong', 'id': _socketID});
    } else { // otherwise, msg should be song info.
      developer.log('Received Message: $event', time: DateTime.now(), name: 'Info Websocket');
      _outStreamController.add(msg);
    }
  }

}