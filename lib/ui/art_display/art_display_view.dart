import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class ArtDisplayView extends StatelessWidget {
  const ArtDisplayView({super.key, required this.viewModel});

  final ArtDisplayModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.passthrough,
      children: [
        ColoredBox( // background color for when images aren't square
          color: MediaQuery.platformBrightnessOf(context) == Brightness.dark? Colors.black : Colors.white,
        ),
        ClipRect( // actual image container (ClipRect to prevent blur from escaping)
          child: ImageFiltered(
            enabled: viewModel.hide, // whether to activate the blur or not
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
            child: ListenableBuilder(
              listenable: viewModel, 
              builder: (_, __) => viewModel.albumArt
            ),
          ),
        ),
        Positioned( // visibility toggle button (positioning)
          top: 0,
          left: 0,
          child: Container( // for background color
            color: Colors.black54,
            child: SizedBox(
              width: app_style.windowIconBoxSize,
              height: app_style.windowIconBoxSize,
              child: IconButton(
                icon: Icon(
                  viewModel.hide? Icons.visibility_off : Icons.visibility,
                  color: Colors.white
                ),
                iconSize: app_style.windowIconSize,
                padding: const EdgeInsets.all(0), // prevents default 8.0 padding, which off-centers icon.
                style: ButtonStyle( // causes the entire area to highlight on hover, instead of a circle.
                  shape: WidgetStatePropertyAll(
                    LinearBorder(),
                  ),
                ),
                onPressed: () => viewModel.toggleAlbumArt(),
              ),
            ),
          )
        ),
      ],
    );
  }
}