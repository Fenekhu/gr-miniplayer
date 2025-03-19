import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/rating_favorite_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key, required this.viewModel});

  final RatingFavoriteModel viewModel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RatingFavoriteStatus>(
      stream: viewModel.ratingFavoriteStream,
      initialData: RatingFavoriteStatus.empty(),
      builder: (context, snapshot) {
        final bool favorited = snapshot.data?.favorite ?? false;

        return SizedBox(
          width: app_style.controlIconBoxSize,
          height: app_style.controlIconBoxSize,
          child: IconButton(
            icon: const Icon(Icons.favorite),
            color: favorited? Colors.red : null,
            iconSize: app_style.controlIconSize,
            padding: const EdgeInsets.all(0),
            tooltip: viewModel.isLoggedIn? null : 'Log in to favorite',
            onPressed: viewModel.isLoggedIn? viewModel.toggleFavorite : null, 
          ),
        );
      }
    );
  }
}