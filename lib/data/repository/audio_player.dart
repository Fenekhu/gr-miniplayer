import 'dart:developer' as developer;
import 'dart:ui';

import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:result_dart/result_dart.dart';

class AudioPlayer {
  static Future<void> ensureInitialized() async {
    JustAudioMediaKit.title = app_info.name;
    JustAudioMediaKit.pitch = false;
    JustAudioMediaKit.ensureInitialized(macOS: true);
  }

  AudioPlayer() : 
    _jaPlayer = ja.AudioPlayer(
      userAgent: app_info.userAgent,
    )
    {
      _jaPlayer.setVolume(clampDouble(app_settings.playerVolume, 0, 1));
      playerStateStream = _jaPlayer.playerStateStream;
      volumeStream = _jaPlayer.volumeStream;
      endpoint = app_settings.streamEndpoint;
    }
  
  void dispose() async {
    await _jaPlayer.dispose();
  }

  late final Stream<ja.PlayerState> playerStateStream;
  late final Stream<double> volumeStream;

  final ja.AudioPlayer _jaPlayer;
  StreamEndpoint? _endpoint;

  final _pauseWatch = Stopwatch();
  Duration? _pausePos;

  StreamEndpoint? get endpoint => _endpoint;

  set endpoint(StreamEndpoint? value) {
    if (_endpoint == value || value == null) return;
    _endpoint = value;
    _pausePos = null;
    _pauseWatch.stop();
    _pauseWatch.reset();

    _updateAudioSource().then((result) => result
      .onFailure((e) {
        developer.log("Error updating audio source", time: DateTime.now(), name: "Audio Player", error: e);
      })
      .onSuccess((_) {
        String? path = (_jaPlayer.audioSource as ja.UriAudioSource?)?.uri.path;
        developer.log("Set endpoint to $path}", time: DateTime.now(), name: "Audio Player");
      })
    );
  }

  set volume(double value) {
    _jaPlayer.setVolume(value);
  }

  /// This won't resolve until content finishes playing.
  /// On a livestream, this should never resolve.
  /// Maybe use this to detect an error if it ever does resolve?
  Future<void> play() async {
    if (_pausePos != null) {
      await _jaPlayer.seek(_pausePos! + _pauseWatch.elapsed);
      _pausePos = null;
      _pauseWatch.stop();
      _pauseWatch.reset();
    }

    return _jaPlayer.play();
  }

  Future<void> stop() async {
    await _jaPlayer.stop();
    _pausePos = null;
    _pauseWatch.stop();
    _pauseWatch.reset();
  }

  Future<void> pause() async {
    await _jaPlayer.pause();
    _pausePos = _jaPlayer.position;
    _pauseWatch.reset();
    _pauseWatch.start();
  }

  /// Either pause or stop the stream, depending on app_settings.cachingPause
  Future<void> pauseOrStop() async {
    app_settings.cachingPause ? await pause() : await stop();
  }

  AsyncResult<Unit> _updateAudioSource() async {
    if (_endpoint == null) {
      return Failure(Exception('Endpoint is null'));
    }

    bool wasPlaying = _jaPlayer.playing;
    await stop();
    try {

      await _jaPlayer.setAudioSource(ja.AudioSource.uri(_endpoint!.uri), preload: false);

    } on ja.PlayerException catch (e) {
      return Failure(Exception('Player error ${e.code}: ${e.message}'));
    } on ja.PlayerInterruptedException catch (e) {
      return Failure(Exception('Player interrupted: ${e.message}'));
    } catch (e) {
      return Failure(Exception("Player error unknown: $e"));
    }

    if (wasPlaying) play();

    return Success(unit);
  }
}