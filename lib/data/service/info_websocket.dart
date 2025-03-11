import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:result_dart/result_dart.dart';

/// Websocket handler for the live song info
class InfoWebsocket {
  InfoWebsocket()
    : _httpClient = HttpClient()..userAgent = app_info.userAgent,
      _outStreamController = StreamController<Map<String, dynamic>>();

  final HttpClient _httpClient;
  WebSocket? _webSocket;
  int _socketID = 0; // used by the manual ping/pong
  final StreamController<Map<String, dynamic>> _outStreamController;

  Duration? _retryDelay; // if stream connection issue
  /// outgoing live song info stream
  Stream<Map<String, dynamic>> get infoStream => _outStreamController.stream;

  /// cleans up client and stream resources.
  void dispose() {
    _webSocket?.close(WebSocketStatus.goingAway);
    _httpClient.close();
    _outStreamController.close();
  }

  /// connects to the websocket. Will not complete until successful connection or complete failure (retryDelay=null)
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
        break;
      } catch(e, trace) {
        developer.log('Connection Error', time: DateTime.now(), name:'Info Websocket', error: e, stackTrace: trace);
        developer.log('Retrying in ${_retryDelay!.inSeconds} seconds', time: DateTime.now(), name:'Info Websocket');
        if (_retryDelay == null) return Failure(Exception('Could not connect to websocket'));
        await Future.delayed(_retryDelay!);
      }
    } while (_retryDelay != null);

    _webSocket?.listen(_handleData, onError: _handleError, cancelOnError: true);

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
    _webSocket = null;
    if (_retryDelay != null) {
      developer.log('Reconnecting in ${_retryDelay!.inSeconds} seconds', time: DateTime.now(), name:'Info Websocket');
      Future.delayed(_retryDelay!, () => connect(_retryDelay));
    }
  }

  void _handleData(dynamic event) {
    final msg = jsonDecode(event) as Map<String, dynamic>;

    bool tryEq(String key, dynamic value) {
      return msg.containsKey(key) && msg[key] == value;
    }


    if (tryEq('message', 'welcome')) { // handle welcome message
      developer.log('Received Message: $event', time: DateTime.now(), name: 'Info Websocket');
      _socketID = msg['id'];
    } else if (tryEq('message', 'ping')) { // if ping, respond with pong
      _sendJson({'message': 'pong', 'id': _socketID});
    } else { // otherwise, should be song info.
      developer.log('Received Message: $event', time: DateTime.now(), name: 'Info Websocket');
      _outStreamController.add(msg);
    }
  }

}