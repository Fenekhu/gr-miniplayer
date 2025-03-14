import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';

class ArtDisplayView extends StatelessWidget {
  const ArtDisplayView({super.key, required this.viewModel});

  final ArtDisplayModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.passthrough,
        children: [
          ColoredBox(
            color: MediaQuery.platformBrightnessOf(context) == Brightness.dark? Colors.black : Colors.white,
          ),
          ClipRect(
            child: ImageFiltered(
              enabled: viewModel.hide,
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
              child: ListenableBuilder(listenable: viewModel, builder: (_, __) => viewModel.albumArt),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              color: Colors.black54,
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  icon: Icon(
                    viewModel.hide? Icons.visibility_off : Icons.visibility,
                    color: Colors.white
                  ),
                  iconSize: 16,
                  padding: const EdgeInsets.all(0),
                  style: ButtonStyle(
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
      ),
    );
  }
}