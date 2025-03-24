import 'package:flutter/material.dart';
import 'package:gr_miniplayer/domain/player_state.dart';
import 'package:gr_miniplayer/ui/control_bar/playback_control/playback_control_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class PlaybackControlView extends StatelessWidget {
  const PlaybackControlView({super.key, required this.viewModel});

  final PlaybackControlModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_style.controlIconBoxSize,
      height: app_style.controlIconBoxSize,
      child: StreamBuilder<PlayerState>(
        stream: viewModel.playerStateStream, 
        builder: (context, snapshot) { // build play/stop/loading icon based on player state
          final PlayerState? playerState = snapshot.data;
          final ProcessingState? processingState = playerState?.processingState;
          final bool? playing = playerState?.playing;

          final IconButton playButton = IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: app_style.controlIconSize,
            padding: const EdgeInsets.all(0),
            onPressed: viewModel.play,
          );

          // show a loading circle when its loading (playing will be true)
          if (processingState == ProcessingState.loading) {
            return CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
            );
          } else if (playing != true) {
            return playButton;
          } else if (processingState != ProcessingState.completed) { // playing && (buffering || idle(shouldn't happen)) => show stop button
            return IconButton(
              icon: const Icon(Icons.stop),
              iconSize: app_style.controlIconSize,
              padding: const EdgeInsets.all(0),
              onPressed: viewModel.stop, 
            );
          } else { // playing && completed (means something went wrong, a live stream should never complete)
            return playButton;
          }
        },
      ),
    );
  }
}