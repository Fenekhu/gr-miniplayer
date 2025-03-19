import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/domain/song_info.dart';

class RatingFavoriteModel {
  RatingFavoriteModel({required SongInfoRepo songInfoRepo, required UserResources userResources}) :
    _songInfoRepo = songInfoRepo,
    _userResources = userResources {
      _songInfoRepo.infoStream.listen(onSongInfo);
    }
  
  final SongInfoRepo _songInfoRepo;
  final UserResources _userResources;

  String? _songID;

  Stream<RatingFavoriteStatus> get ratingFavoriteStream => _userResources.ratingFavoriteStream;

  bool get isLoggedIn => _userResources.isLoggedIn;

  void onSongInfo(SongInfo info) {
    _songID = info.songID;
    _userResources.updateRatingAndFavoriteStatus(_songID!);
  }

  Future<void> setRating(int rating) async {
    if (_songID != null) await _userResources.submitRating(_songID!, rating);
  }

  Future<void> toggleFavorite() async {
    if (_songID != null) await _userResources.toggleFavorite(_songID!);
  }
}