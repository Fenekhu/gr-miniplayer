import 'package:flutter/material.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/ui/history/history_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class HistoryView extends StatelessWidget {
  const HistoryView({super.key, required this.viewModel});

  final HistoryModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.listenable, 
      builder: (context, child) {
        int i = 0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            app_style.mainContentHorizontalPadding, 
            4, 
            app_style.mainContentHorizontalPadding, 
            app_style.mainContentSectionSpacing
          ),
          child: Column(
            spacing: 8,
            children: [
              for (HistoryTrack track in viewModel.list.reversed.skip(1)) 
                _TrackItem(key: Key('ht${i++}'), track: track, viewModel: viewModel),
            ],
          ),
        );
      },
    );
  }
}

class _TrackItem extends StatelessWidget {
  const _TrackItem({
    super.key,
    required this.track,
    required this.viewModel,
  });

  final HistoryTrack track;
  final HistoryModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        SizedBox.square(
          dimension: 40,
          child: viewModel.getThumbnail(track.albumArt),
        ),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.title,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Text(
              '${track.album} — ${track.circle}',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: app_style.otherInfoStyle,
            ),
          ],
        ))
      ],
    );
  }
}