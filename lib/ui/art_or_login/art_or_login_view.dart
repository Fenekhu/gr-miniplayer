import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_view.dart';
import 'package:gr_miniplayer/ui/art_or_login/art_or_login_model.dart';
import 'package:gr_miniplayer/ui/login_page/login_page_model.dart';
import 'package:gr_miniplayer/ui/login_page/login_page_view.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class ArtOrLoginView extends StatelessWidget {
  const ArtOrLoginView({super.key, required this.viewModel});

  final ArtOrLoginModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: StreamBuilder(
          initialData: false,
          stream: viewModel.needsLoginPageStream, 
          builder: (context, snapshot) {
            return (snapshot.data ?? false)?
              LoginPageView(
                viewModel: LoginPageModel(
                  userResources: context.read(),
                ),
              )
              :
              ArtDisplayView(
                viewModel: ArtDisplayModel(
                  hiddenArtManager: context.read(), 
                  songInfoRepo: context.read(),
                  artProvider: context.read(),
                )
              );
          },
        ),
      ),
    );
  }
}