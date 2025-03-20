
import 'dart:async';
import 'dart:developer';

import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/domain/song_info.dart';

/// Bridge to trigger a rating/favorite status update when a new song comes.
class RatingFavoriteBridge {
  RatingFavoriteBridge({required SongInfoRepo songInfoRepo, required UserResources userResources}) :
    _songInfoRepo = songInfoRepo,
    _userResources = userResources {
      _infoStreamSubscription = _songInfoRepo.infoStream.listen(_onSongInfo);
      _userDataStreamSubscription = _userResources.userDataStream.listen(_onUserData);
    }
  
  final SongInfoRepo _songInfoRepo;
  final UserResources _userResources;

  late final StreamSubscription<SongInfo> _infoStreamSubscription;
  late final StreamSubscription<UserSessionData> _userDataStreamSubscription;

  String? get _songID => _songInfoRepo.latestInfo?.songID;

  bool get isLoggedIn => _userResources.isLoggedIn;

  Stream<RatingFavoriteStatus> get ratingFavoriteStream => _userResources.ratingFavoriteStream;
  Stream<UserSessionData> get userDataStream => _userResources.userDataStream;

  void _onSongInfo(SongInfo info) {
    _userResources.updateRatingAndFavoriteStatus(info.songID);
  }

  void _onUserData(UserSessionData data) {
    log('onUserData: ${data.username}', name: 'Rating Favorite Bridge');
    if (_songID != null) _userResources.updateRatingAndFavoriteStatus(_songID!);
  }

  void dispose() {
    _infoStreamSubscription.cancel();
    _userDataStreamSubscription.cancel();
  }

  Future<void> setRating(int rating) async {
    if (_songID != null) await _userResources.submitRating(_songID!, rating);
  }

  Future<void> toggleFavorite() async {
    if (_songID != null) await _userResources.toggleFavorite(_songID!);
  }
}