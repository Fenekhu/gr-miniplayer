import 'dart:developer' as developer;
import 'dart:ui';

import 'package:gr_miniplayer/domain/player_state.dart';
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
      playerStateStream = _jaPlayer.playerStateStream.map((event) => PlayerState.fromJA(event)).asBroadcastStream();
    }
  
  /// dispose underlying resources
  void dispose() async {
    await _jaPlayer.dispose();
  }

  late final Stream<PlayerState> playerStateStream;
  Stream<double> get volumeStream => _jaPlayer.volumeStream;

  final ja.AudioPlayer _jaPlayer; // underlying implementation player
  StreamEndpoint? _endpoint; // the current endpoint that is being played.

  StreamEndpoint? get endpoint => _endpoint;

  set endpoint(StreamEndpoint? value) {
    // early exit if value is null or the endpoint isn't actually being changed.
    if (_endpoint == value || value == null) return;
    _endpoint = value;

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
    // seek to the head of the livestream. 
    // by default, JustAudio attempts to seek to the last play position after both stop and pause.
    // MVP player does not allow seeks on livestreams, so this cancels JustAudio's seek attempt.
    _jaPlayer.seek(null);
    return _jaPlayer.play();
  }

  Future<void> stop() => _jaPlayer.stop();
  Future<void> pause() => _jaPlayer.pause();

  /// Either pause or stop the stream, depending on app_settings.cachingPause
  Future<void> pauseOrStop() => app_settings.cachingPause ? pause() : stop();

  /// updates the audio source for the underlying audio player.
  AsyncResult<Unit> _updateAudioSource() async {
    if (_endpoint == null) {
      return Failure(Exception('Endpoint is null'));
    }

    // store whether the player was playing so we can resume after switching.
    bool wasPlaying = _jaPlayer.playing;
    await stop();
    try {

      await _jaPlayer.setAudioSource(
        ja.AudioSource.uri(_endpoint!.uri), 
        initialIndex: 0,
        initialPosition: Duration.zero,
        preload: false,
      );

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