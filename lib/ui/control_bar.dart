import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_model.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_view.dart';
import 'package:provider/provider.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 5.0/6,
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InfoDisplayView(
            viewModel: InfoDisplayModel(
              songInfoRepo: context.read(),
            )
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     VolumeControl(widget._audioState),
          //     Spacer(),
          //     PlaybackControl(widget._audioState),
          //     Spacer(),
          //     SettingsControl(),
          //   ],
          // ),
        ],
      ),
    );
  }
}