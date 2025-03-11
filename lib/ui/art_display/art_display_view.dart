import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';

class ArtDisplayView extends StatelessWidget {
  const ArtDisplayView({super.key, required this.viewModel});

  final ArtDisplayModel viewModel;

  @override
  Widget build(BuildContext context0) {
    return ListenableBuilder(
      listenable: viewModel, 
      builder: (context1, _) {
        return Stack(
          alignment: Alignment.topCenter,
          fit: StackFit.passthrough,
          children: [
            ClipRect(
              child: ImageFiltered(
                enabled: viewModel.hide,
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
                child: viewModel.albumArt,
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
        );
      },
    );
  }
}