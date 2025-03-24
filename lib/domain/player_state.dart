import 'package:gr_miniplayer/domain/song_info.dart';
import 'package:just_audio/just_audio.dart' as ja;

// Copying the JustAudio enum so that other files are not dependent on JustAudio.
/// Enumerates the different processing states of a player.
enum ProcessingState {
  /// The player has not loaded an [AudioSource].
  idle,

  /// The player is loading an [AudioSource].
  loading,

  /// The player is buffering audio and unable to play.
  buffering,

  /// The player is has enough audio buffered and is able to play.
  ready,

  /// The player has reached the end of the audio.
  completed,
  
  ;

  static ProcessingState fromJA(ja.ProcessingState jaState) {
    return switch (jaState) {
      ja.ProcessingState.idle => idle,
      ja.ProcessingState.loading => loading,
      ja.ProcessingState.buffering => buffering,
      ja.ProcessingState.ready => ready,
      ja.ProcessingState.completed => completed,
    };
  }
}

// Copying the JustAudio state so other files are not dependent on JustAudio
/// Encapsulates the playing and processing states. These two states vary
/// orthogonally, and so if [processingState] is [ProcessingState.buffering],
/// you can check [playing] to determine whether the buffering occurred while
/// the player was playing or while the player was paused.
class PlayerState {
  /// Whether the player will play when [processingState] is
  /// [ProcessingState.ready].
  final bool playing;

  /// The current processing state of the player.
  final ProcessingState processingState;

  PlayerState({required this.playing, required this.processingState});

  PlayerState.fromJA(ja.PlayerState jaState): 
    playing = jaState.playing, processingState = ProcessingState.fromJA(jaState.processingState);
}

/// Represents the current song and player state
class PlayerInfoState {
  final bool playing;
  final ProcessingState processingState;
  final SongInfo songInfo;

  const PlayerInfoState({required this.playing, required this.processingState, required this.songInfo});
}