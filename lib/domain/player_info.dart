import 'package:just_audio/just_audio.dart' as ja;

/// All the information about a song usually given from the live info websocket.
class SongInfo {
  final String songID;
  final String title;
  final String artist;
  final String albumID;
  final String album;
  final String circle;
  final int    year;
  final String albumArt;
  final int    duration;
  final int    played;
  final int    remaining;

  const SongInfo({
    required this.songID, 
    required this.title, 
    required this.artist, 
    required this.albumID, 
    required this.album, 
    required this.circle, 
    required this.year, 
    required this.albumArt,
    required this.duration, 
    required this.played, 
    required this.remaining,
  });
}

class HistoryTrack {
  final int played;
  final String title;
  final String artist;
  final String albumID;
  final String album;
  final String albumArt;
  final String circle;
  final int track;

  const HistoryTrack({
    required this.played, 
    required this.title, 
    required this.artist, 
    required this.albumID, 
    required this.album, 
    required this.albumArt, 
    required this.circle, 
    required this.track
  });
}

/// represents all data needed to display the m:ss --------------- m:ss bar
class ProgressStatus {
  final String elapsed;
  final String total;
  final double value;

  const ProgressStatus({required this.elapsed, required this.total, required this.value});
}

/// represents whether a specific album is hidden or not.
class ArtHidingStatus {
  final String albumID;
  final bool hide;

  const ArtHidingStatus(this.albumID, this.hide);
}

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