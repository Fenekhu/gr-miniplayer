import 'dart:io';

import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:smtc_windows/smtc_windows.dart';

/// SMTCWindows implementation of AudioService
class AudioServiceSmtc extends AudioServicePlatform {
  static Future<void> ensureInitialized() async {
    if (Platform.isWindows) { // we only need SMTCWindows on Windows.
      registerWith(); // normally this is automatically platform-conditionally performed by dart for all plugins, but this isn't technically a plugin.
      await SMTCWindows.initialize();
    }
  }

  /// Registers the plugin with AudioServicePlatform.
  // note that this is not actually a plugin, so is called in ensureInitialized().
  static void registerWith() {
    AudioServicePlatform.instance = AudioServiceSmtc();
  }



  late final SMTCWindows _smtc;
  AudioHandlerCallbacks? _callbacks;
  Duration _position = Duration.zero;

  /// called when smtc sees a media button is pressed.
  /// this is what actually routes SMTC control events to our handler.
  void _onControl(PressedButton button) {
    if (_callbacks == null) return;

    switch (button) {
      case PressedButton.play: _callbacks!.play(const PlayRequest());
      case PressedButton.pause: _callbacks!.pause(const PauseRequest());
      default:
    }
  }

  // an initialization function i think
  @override
  Future<void> configure(ConfigureRequest request) async {
    _smtc = SMTCWindows(
      config: const SMTCConfig(
        playEnabled: true, 
        pauseEnabled: true, 
        stopEnabled: false, 
        nextEnabled: false, 
        prevEnabled: false, 
        fastForwardEnabled: false, 
        rewindEnabled: false,
      ),
      shuffleEnabled: false,
      repeatMode: RepeatMode.none,
      enabled: true,
    );

    _smtc.buttonPressStream.listen(_onControl);

    // create a stream that outputs the updated position every second,
    // then listen to its output to update the SMTC position info.
    Stream.periodic(
      const Duration(seconds: 1),
      (_) { // output the pre-updated position. equivalent to `return _position++` if _position was seconds.
        final tmp = _position;
        _position += const Duration(seconds: 1);
        return tmp;
      }
    ).listen((position) => _smtc.setPosition(position));
  }

  /// Called when the handler sends an event back to SMTC, such as the player no longer playing.
  @override
  Future<void> setState(SetStateRequest request) async {
    _smtc.setPlaybackStatus(request.state.playing? PlaybackStatus.playing : PlaybackStatus.paused);
    // note: we don't update the position, because 
    // A) seeking is not permitted.
    // B) the position should reflect the websocket info, not the actual play position.
  }

  /// Called when the handler is given media info to send to SMTC.
  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    _smtc.updateMetadata(MusicMetadata(
      album: request.mediaItem.album,
      albumArtist: request.mediaItem.extras?['circle'],
      artist: request.mediaItem.artist,
      thumbnail: request.mediaItem.artUri?.toString(),
      title: request.mediaItem.title,
    ));

    _position = Duration(seconds: request.mediaItem.extras?['elapsed'] ?? 0);
    _smtc.updateTimeline(PlaybackTimeline(
      startTimeMs: 0, 
      endTimeMs: request.mediaItem.duration?.inMilliseconds ?? 0, 
      positionMs: _position.inMilliseconds,
    ));
  }

  /// Links this service to our handler.
  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    _callbacks = callbacks;
  }
}