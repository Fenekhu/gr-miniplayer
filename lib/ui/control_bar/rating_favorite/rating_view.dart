import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/rating_favorite_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class RatingView extends StatelessWidget {
  RatingView({super.key, required this.viewModel});

  final RatingFavoriteModel viewModel;
  final MenuController _menuController = MenuController();

  void _toggleMenu() {
    _menuController.isOpen? _menuController.close() : _menuController.open();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RatingFavoriteStatus>(
      stream: viewModel.ratingFavoriteStream,
      initialData: RatingFavoriteStatus.empty(),
      builder: (context, snapshot) {
        final int rating = snapshot.data?.rating ?? 0;
        final bool ratedThisYear = snapshot.data?.year == DateTime.now().year;

        Color? starColor;
        if (rating > 0) {
          starColor = ratedThisYear ? Colors.amber : Colors.blue;
        }

        return SizedBox(
          width: app_style.controlIconBoxSize,
          height: app_style.controlIconBoxSize,
          child: MenuAnchor(
            controller: _menuController,
            clipBehavior: Clip.none,
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color.lerp(Theme.of(context).colorScheme.surface, Colors.grey, 0.25)),
              visualDensity: VisualDensity.compact,
            ),
            menuChildren: [
              for(int i = 5; i >= 1; i--) 
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SizedBox(
                      width: app_style.controlIconBoxSize,
                      height: app_style.controlIconBoxSize,
                      child: IconButton(
                        icon: const Icon(null),
                        onPressed: () => viewModel.setRating(i), 
                      ),
                    ),
                    IgnorePointer(
                      child: Icon(
                        Icons.star,
                        color: rating >= i? starColor : null,
                        size: app_style.controlIconSize,
                      ),
                    ),
                    IgnorePointer(
                      child: Text(
                        i.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.surface),
                      ),
                    )
                  ],
                )
            ],
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.star),
                  color: starColor,
                  iconSize: app_style.controlIconSize,
                  padding: const EdgeInsets.all(0),
                  tooltip: viewModel.isLoggedIn? null : 'Log in to rate',
                  onPressed: viewModel.isLoggedIn? _toggleMenu : null, 
                ),
                IgnorePointer(
                  child: Text(
                    rating == 0? '' : rating.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ]
            ),
          ),
        );
      }
    );
  }
}