import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/control_bar/playback_control/playback_control_model.dart';
import 'package:gr_miniplayer/ui/control_bar/playback_control/playback_control_view.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/favorite_view.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/rating_favorite_model.dart';
import 'package:gr_miniplayer/ui/control_bar/rating_favorite/rating_view.dart';
import 'package:gr_miniplayer/ui/control_bar/settings/settings_model.dart';
import 'package:gr_miniplayer/ui/control_bar/settings/settings_view.dart';
import 'package:gr_miniplayer/ui/control_bar/volume_control/volume_control_model.dart';
import 'package:gr_miniplayer/ui/control_bar/volume_control/volume_control_view.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_model.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_view.dart';
import 'package:provider/provider.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    // create this beforehand because it is shared by the rating and favorite buttons.
    final ratingFavoriteModel = RatingFavoriteModel(
      bridge: context.read(),
    );

    return FractionallySizedBox( // constrain the side of the info and button display
      widthFactor: 5.0/6,
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InfoDisplayView( // song title and album + artist info, progress text and bar
            viewModel: InfoDisplayModel(
              songInfoRepo: context.read(),
            )
          ),
          Row( // buttons
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VolumeControlView(
                viewModel: VolumeControlModel(
                  audioPlayer: context.read(),
                ),
              ),
              RatingView(
                viewModel: ratingFavoriteModel
              ),
              PlaybackControlView(
                viewModel: PlaybackControlModel(
                  audioPlayer: context.read(),
                ),
              ),
              FavoriteView(
                viewModel: ratingFavoriteModel
              ),
              SettingsMenuView(
                viewModel: SettingsMenuModel(
                  audioPlayer: context.read(),
                  userResources: context.read(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}