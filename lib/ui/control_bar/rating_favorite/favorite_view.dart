import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/rating_favorite_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key, required this.viewModel});

  final RatingFavoriteModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_style.controlIconBoxSize,
      height: app_style.controlIconBoxSize,
      child: StreamBuilder<UserSessionData>(
        stream: viewModel.bridge.userDataStream, // respond to changes in login status
        initialData: UserSessionData.fromStorage(),
        builder: (context, snapshot0) {
          final bool isLoggedIn = snapshot0.data?.asi.isNotEmpty ?? false;
        
          return StreamBuilder<RatingFavoriteStatus>(
            stream: viewModel.bridge.ratingFavoriteStream, // respond to changes in song favorite status
            initialData: RatingFavoriteStatus.empty(),
            builder: (context, snapshot1) {
              final bool favorited = isLoggedIn && (snapshot1.data?.favorite ?? false);
              return IconButton(
                icon: const Icon(Icons.favorite),
                color: favorited? Colors.red : null,
                iconSize: app_style.controlIconSize,
                padding: const EdgeInsets.all(0),
                tooltip: isLoggedIn? null : 'Log in to favorite',
                onPressed: isLoggedIn? viewModel.bridge.toggleFavorite : null, 
              );
            }
          );
        },
      ),
    );
  }
}