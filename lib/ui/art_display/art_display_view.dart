import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class ArtDisplayView extends StatelessWidget {
  const ArtDisplayView({super.key, required this.viewModel});

  final ArtDisplayModel viewModel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArtHidingStatus>(
      stream: viewModel.visibilityStream,
      initialData: ArtHidingStatus('0', false),
      builder: (context0, snapshot0) {
        return StreamBuilder<SongInfo>(
          stream: viewModel.infoStream,
          builder: (context1, snapshot1) {
            final data1 = snapshot1.data ?? viewModel.latestInfo;
            final albumArtID = data1?.albumArt ?? '';
            final statusAlbumID = snapshot0.data?.albumID ?? '0';
            final infoAlbumID = data1?.albumID ?? '0';
            final hide = 
              statusAlbumID != '0' && 
              infoAlbumID != '0' && 
              statusAlbumID == infoAlbumID && 
              (snapshot0.data?.hide ?? false);
            return Stack(
              alignment: Alignment.topCenter,
              fit: StackFit.passthrough,
              children: [
                ColoredBox( // background color for when images aren't square
                  color: MediaQuery.platformBrightnessOf(context) == Brightness.dark? Colors.black : Colors.white,
                ),
                ClipRect( // actual image container (ClipRect to prevent blur from escaping)
                  child: ImageFiltered(
                    enabled: hide, // whether to activate the blur or not
                    imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50, tileMode: TileMode.decal),
                    child: viewModel.getAlbumArt(albumArtID),
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
                          hide? Icons.visibility_off : Icons.visibility,
                          color: Colors.white
                        ),
                        iconSize: app_style.windowIconSize,
                        padding: const EdgeInsets.all(0), // prevents default 8.0 padding, which off-centers icon.
                        style: ButtonStyle( // causes the entire area to highlight on hover, instead of a circle.
                          shape: WidgetStatePropertyAll(
                            LinearBorder(),
                          ),
                        ),
                        onPressed: () => viewModel.toggleAlbumArt(infoAlbumID),
                      ),
                    ),
                  )
                ),
              ],
            );
          },
        );
      },
    );
  }
}