import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:gr_miniplayer/data/repository/art_cache.dart';
import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

/// Interfaces with Audio Service / Media Transport / MPRIS events.
/// Sends updated song and playback state information to the systems
/// and routes play/pause events to the audio player.
class MyAudioServiceHandler extends BaseAudioHandler {
  static int _mediaID = 0; // each media information update supposedly needs a unique id. This is updated each time one is created.
  static late MyAudioServiceHandler _instance;
  static MyAudioServiceHandler get instance => _instance;

  /// registers this class as the handler for Audio Service
  static Future<void> ensureInitialized() async {
    _instance = await AudioService.init(
      builder: () => MyAudioServiceHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'gr_miniplayer'
      )
    );
  }

  ArtCache? _artProvider; // for getting the path of locally cached images (to prevent duplicate calls to the server)
  AudioPlayer? _player; 
  SongInfoRepo? _infoRepo;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<SongInfo>? _infoStreamSub;

  /// callback for the live info updates. updates the platform media system with current song info.
  Future<void> _onSongInfo(SongInfo info) async {
    mediaItem.add(MediaItem(
      id: (_mediaID++).toString(), // needs to be unique apparently.
      title: info.title,
      album: info.album,
      artUri: (await _artProvider?.getImageFile(info.albumArtID))?.absolute.uri,
      artist: info.artist,
      duration: Duration(seconds: info.duration),
      isLive: true,
      extras: {
        'played': info.played,
        'circle': info.circle,
      }
    ));
  }

  /// callback for the audio player state events. matches the media system's playing status to the player.
  void _onPlayerState(PlayerState state) {
    playbackState.add(PlaybackState(
      processingState: switch (state.processingState) {
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.completed => AudioProcessingState.completed,
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.ready => AudioProcessingState.ready,
      },
      playing: state.playing,
      controls: [
        state.playing? MediaControl.pause : MediaControl.play,
      ],
    ));
  }

  void setArtCache(ArtCache cache) {
    _artProvider = cache;
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

  // called by media control buttons (ie, fn+f6)
  @override Future<void> play() async => await _player?.play();
  @override Future<void> pause() async => await _player?.pauseOrStop();

}