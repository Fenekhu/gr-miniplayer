import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/control_bar/playback_control/playback_control_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;
import 'package:just_audio/just_audio.dart' as ja;

class PlaybackControlView extends StatelessWidget {
  const PlaybackControlView({super.key, required this.viewModel});

  final PlaybackControlModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_style.controlIconBoxSize,
      height: app_style.controlIconBoxSize,
      child: StreamBuilder<ja.PlayerState>(
        stream: viewModel.playerStateStream, 
        builder: (context, snapshot) {
          final ja.PlayerState? playerState = snapshot.data;
          final ja.ProcessingState? processingState = playerState?.processingState;
          final bool? playing = playerState?.playing;

          final IconButton playButton = IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: app_style.controlIconSize,
            padding: const EdgeInsets.all(0),
            onPressed: viewModel.play,
          );

          if (processingState == ja.ProcessingState.loading) {
            return CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
            );
          } else if (playing != true) {
            return playButton;
          } else if (processingState != ja.ProcessingState.completed) {
            return IconButton(
              icon: const Icon(Icons.stop),
              iconSize: app_style.controlIconSize,
              padding: const EdgeInsets.all(0),
              onPressed: viewModel.stop, 
            );
          } else {
            return playButton;
          }
        },
      ),
    );
  }
}