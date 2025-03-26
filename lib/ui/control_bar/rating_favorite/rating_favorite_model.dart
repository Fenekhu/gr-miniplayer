import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/domain/rating_favorite_bridge.dart';
import 'package:gr_miniplayer/util/extensions/result_ext.dart';

class RatingFavoriteModel {
  RatingFavoriteModel({required RatingFavoriteBridge bridge}) :
    _bridge = bridge;
  
  final RatingFavoriteBridge _bridge;

  Stream<RatingFavoriteStatus> get ratingFavoriteStream => _bridge.ratingFavoriteStream;
  Stream<UserSessionData> get userDataStream => _bridge.userDataStream;

  Future<void> setRating(int rating) async {
    await _bridge.setRating(rating).logOnFailure('Rating Favorite');
  }

  Future<void> toggleFavorite() async {
    await _bridge.toggleFavorite().logOnFailure('Rating Favorite');
  }
}