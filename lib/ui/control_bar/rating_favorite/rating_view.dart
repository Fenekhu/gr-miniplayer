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
    return SizedBox(
      width: app_style.controlIconBoxSize,
      height: app_style.controlIconBoxSize,
      child: StreamBuilder<RatingFavoriteStatus>(
        stream: viewModel.bridge.ratingFavoriteStream, // respond to changes in song rating status
        initialData: RatingFavoriteStatus.empty(),
        builder: (context, snapshot0) {
          final int rating = snapshot0.data?.rating ?? 0;
          final bool ratedThisYear = snapshot0.data?.year == DateTime.now().year;

          // stars are yellow if rated this year, blue otherwise.
          // this is to know which ratings count towards the station's yearly top 100.
          // color will remain null (default) if unrated.
          Color? starColor;
          if (rating > 0) {
            starColor = ratedThisYear ? Colors.amber : Colors.blue;
          }
      
          return MenuAnchor(
            controller: _menuController,
            clipBehavior: Clip.none,
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Color.lerp(Theme.of(context).colorScheme.surface, Colors.grey, 0.25)),
            ),
            menuChildren: [ // items in the menu popup
              // generate a star for each rating value 1-5.
              // reverse order because menus populate top to bottom.
              for(int i = 5; i >= 1; i--) 
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SizedBox( // star button
                      width: app_style.controlIconBoxSize,
                      height: app_style.controlIconBoxSize,
                      child: IconButton(
                        icon: const Icon(Icons.star),
                        color: rating >= i? starColor : null, // color the star if number <= rating
                        iconSize: app_style.controlIconSize,
                        padding: const EdgeInsets.all(0), // prevent default 8.0 padding
                        onPressed: () => viewModel.bridge.setRating(i), 
                      ),
                    ),
                    IgnorePointer( // text overlay
                      child: Text(
                        i.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.surface),
                      ),
                    )
                  ],
                )
            ],
            child: Stack( // the widget from which the menu will pop up (the rating star button)
              alignment: AlignmentDirectional.center,
              children: [
                StreamBuilder<UserSessionData>(
                  stream: viewModel.bridge.userDataStream,  // respond to changes in login status
                  initialData: UserSessionData.fromStorage(),
                  builder: (context, snapshot1) {
                    final bool isLoggedIn = snapshot1.data?.asi.isNotEmpty ?? false;
                    return IconButton( // the actual button
                      icon: const Icon(Icons.star),
                      color: starColor,
                      iconSize: app_style.controlIconSize,
                      padding: const EdgeInsets.all(0), // prevent default 8.0 padding
                      tooltip: isLoggedIn? null : 'Log in to rate',
                      onPressed: isLoggedIn? _toggleMenu : null, 
                    );
                  }
                ),
                IgnorePointer(
                  child: Text( // draw the rating number over it if its been rated.
                    rating == 0? '' : rating.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.surface),
                  ),
                ),
              ]
            ),
          );
        },
      ),
    );
  }
}