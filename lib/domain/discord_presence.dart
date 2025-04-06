import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;

class DiscordPresence {
  static const Duration _minWaitTime = Duration(seconds: 10);
  static final DiscordPresence _instance = DiscordPresence._();
  static DiscordPresence get instance => _instance;

  static Future<void> ensureInitialized() {
    return FlutterDiscordRPC.initialize('1356706865211379834');
  }

  DiscordPresence._() {
    _isConnectedStreamSub = FlutterDiscordRPC.instance.isConnectedStream.listen(
      (v) {
        log(v? 'connected' : 'disconnected', name: 'Discord RPC');
        _isConnected = v;
      }
    );
  }

  AudioPlayer? _player;
  SongInfoRepo? _infoRepo;
  
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<SongInfo>? _infoStreamSub;
  late StreamSubscription<bool> _isConnectedStreamSub;

  bool _isConnected = false;

  // Discord activity status shouldn't be updated too often.
  // These are used to send the next state after _minWaitTime has passed since the last status update.
  RPCActivity? _nextState;
  DateTime _lastSetTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  bool _isUpdateQueued = false;

  /// Updates the current activity
  Future<void> _sendState() async {
    if (!_isConnected) return;
    _lastSetTime = DateTime.timestamp();
    _isUpdateQueued = false;
    if (_nextState == null) {
      await FlutterDiscordRPC.instance.clearActivity();
    } else {
      await FlutterDiscordRPC.instance.setActivity(activity: _nextState!);
    }
  }

  /// Updates the state once a certain amount of time has passed since the last state update.
  /// Pass null to clear the status.
  /// At minimum, waits until the next async event cycle.
  // This could be changed by manually checking the time difference and circumventing Future.delayed if its <= 0, but I don't see a reason to.
  void _queueState(RPCActivity? state) {
    _nextState = state;
    if (!_isUpdateQueued) {
      Future.delayed(
        (_lastSetTime.add(_minWaitTime)).difference(DateTime.timestamp()), // (lastTime+minWait)-now
        _sendState,
      );
      _isUpdateQueued = true;
    }
  }

  /// Queues state from a given songInfo.
  void _queueFromInfo(SongInfo songInfo) {
    final songStart = (DateTime.timestamp().millisecondsSinceEpoch ~/ 1000 - _infoRepo!.played);

    String? emptyToNull(String v) => v.isEmpty? null : v;

    _queueState(
      RPCActivity(
        details: emptyToNull(songInfo.title),
        state: emptyToNull(songInfo.circle),
        timestamps: RPCTimestamps( 
          start: songStart,
          end: songInfo.duration == 0? null : songStart + songInfo.duration, // start == end seems to break the API
        ),
        assets: RPCAssets(
          largeImage: emptyToNull(songInfo.albumArt) ?? 'icon',
          largeText: emptyToNull(songInfo.album),
        ),
        buttons: const [
          RPCButton(
            label: 'Listen', 
            url: 'https://app.gensokyoradio.net/player'
          ),
          RPCButton(
            label: 'Get Miniplayer',
            url: 'https://github.com/Fenekhu/gr-miniplayer'
          ),
        ],
        activityType: ActivityType.listening,
      )
    );
  }

  void _onPlayerState(PlayerState state) {
    // dont change anything if no song info is available.
    if (_infoRepo?.latestInfo == null) return;

    state.playing? _queueFromInfo(_infoRepo!.latestInfo!) : clearActivity();
  }

  void _onSongInfo(SongInfo info) {
    // early exit if the player isn't set or playing
    if (_player == null || _player!.playing == false) return;

    _queueFromInfo(info);
  }

  void setAudioPlayer(AudioPlayer player) {
    _player = player;
    _playerStateSub?.cancel();
    _playerStateSub = _player!.playerStateStream.listen(_onPlayerState);
  }

  void setSongInfoRepo(SongInfoRepo infoRepo) {
    _infoRepo = infoRepo;
    _infoStreamSub?.cancel();
    _infoStreamSub = _infoRepo!.infoStream.listen(_onSongInfo);
  }

  void clearActivity() => _queueState(null);

  /// By default, connect only in release mode and if discordRPC.enabled in shared_preferences.
  Future<void> maybeConnect({bool connectInDebug = false, bool ignoreSettings = false}) async {
    if (
      (!kDebugMode || connectInDebug) && // check debug mode
      (app_settings.discordRpcEnabled || ignoreSettings)) { // check settings
        return connect();
    }
  }

  Future<void> connect() => FlutterDiscordRPC.instance.connect();
  Future<void> disconnect() => FlutterDiscordRPC.instance.disconnect();

  Future<void> dispose() async {
    _playerStateSub?.cancel();
    _infoStreamSub?.cancel();
    _isConnectedStreamSub.cancel();
    await FlutterDiscordRPC.instance.dispose();
  }
}