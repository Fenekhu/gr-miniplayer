import 'dart:async';
import 'dart:developer' show log;

import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/util/exceptions.dart';
import 'package:gr_miniplayer/util/extensions/result_ext.dart';
import 'package:result_dart/result_dart.dart';

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
    _userResources.updateRatingAndFavoriteStatus(info.songID).logOnFailure('Rating Favorite Bridge');
  }

  void _onUserData(UserSessionData data) {
    log('onUserData: ${data.username}', name: 'Rating Favorite Bridge');
    if (_songID != null) _userResources.updateRatingAndFavoriteStatus(_songID!).logOnFailure('Rating Favorite Bridge');
  }

  Future<void> dispose() async {
    await Future.wait([ // allows operations to happen "simultaneously"
      _infoStreamSubscription.cancel(),
      _userDataStreamSubscription.cancel(),
    ]);
  }

  /// throws `MissingSongIDException` if applicable
  AsyncResult<Unit> setRating(int rating) async {
    if (_songID == null) return Failure(MissingSongIDException());
    return _userResources.submitRating(_songID!, rating);
    
  }

  /// throws `MissingSongIDException` if applicable
  AsyncResult<Unit> toggleFavorite() async {
    if (_songID == null) return Failure(MissingSongIDException());
    return _userResources.toggleFavorite(_songID!);
  }
}