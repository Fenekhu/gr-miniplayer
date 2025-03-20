import 'dart:developer' as developer;
import 'dart:ui';

import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:result_dart/result_dart.dart';

/// An audio player that plays a specific stream endpoint and outputs player state as a stream.
/// Currently, this wraps a just_audio Audio Player.
class AudioPlayer {
  /// Initialize the player backend.
  static Future<void> ensureInitialized() async {
    JustAudioMediaKit.title = app_info.name; // the text that will display in a system Volume Mixer
    JustAudioMediaKit.pitch = false;
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
      macOS: true
    );
  }

  AudioPlayer() : 
    _jaPlayer = ja.AudioPlayer(
      userAgent: app_info.userAgent,
    )
    {
      _jaPlayer.setVolume(clampDouble(app_settings.playerVolume, 0, 1));
      endpoint = app_settings.streamEndpoint;
    }
  
  /// dispose underlying resources
  void dispose() async {
    await _jaPlayer.dispose();
  }

  Stream<ja.PlayerState> get playerStateStream => _jaPlayer.playerStateStream;
  Stream<double> get volumeStream => _jaPlayer.volumeStream;

  final ja.AudioPlayer _jaPlayer; // underlying implementation player
  StreamEndpoint? _endpoint; // the current endpoint that is being played.

  // if cachingPause is enabled, this is used to fast-forward the stream when resuming.
  // this was originally needed because Just Audio's native backends have very long load times,
  // but the Media Kit backend is very fast.
  final _pauseWatch = Stopwatch();
  Duration? _pausePos;

  StreamEndpoint? get endpoint => _endpoint;

  set endpoint(StreamEndpoint? value) {
    // early exit if value is null or the endpoint isn't actually being changed.
    if (_endpoint == value || value == null) return;
    _endpoint = value;
    // the pause information will be invalid after switch endpoints, because the underlying player "resets"
    _pausePos = null;
    _pauseWatch.stop();
    _pauseWatch.reset();

    // update audio source, then log result.
    _updateAudioSource().then((result) => result
      .onFailure((e) {
        developer.log('Error updating audio source', time: DateTime.now(), name: 'Audio Player', error: e);
      })
      .onSuccess((_) {
        String? path = (_jaPlayer.audioSource as ja.UriAudioSource?)?.uri.path;
        developer.log('Set endpoint to $path}', time: DateTime.now(), name: 'Audio Player');
      })
    );
  }

  set volume(double value) {
    _jaPlayer.setVolume(value);
  }

  /// This won't resolve until content finishes playing.
  /// On a livestream, this should never resolve.
  /// In otherwords, this resolving should signal an error (such as connection dropped, or the broadcast server goes down)
  Future<void> play() async {
    // pausePos != null means cachingPause is enabled. So we seek to the "head" of the stream,
    // which is calculated based on where the head was when it was paused and how long it has been.
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

  /// updates the audio source for the underlying audio player.
  AsyncResult<Unit> _updateAudioSource() async {
    if (_endpoint == null) {
      return Failure(Exception('Endpoint is null'));
    }

    // store whether the player was playing so we can resume after switching.
    bool wasPlaying = _jaPlayer.playing;
    await stop();
    try {

      await _jaPlayer.setAudioSource(ja.AudioSource.uri(_endpoint!.uri), preload: false);

    } on ja.PlayerException catch (e) {
      return Failure(Exception('Player error ${e.code}: ${e.message}'));
    } on ja.PlayerInterruptedException catch (e) {
      return Failure(Exception('Player interrupted: ${e.message}'));
    } catch (e) {
      return Failure(Exception('Player error unknown: $e'));
    }

    if (wasPlaying) play();

    return Success(unit);
  }
}