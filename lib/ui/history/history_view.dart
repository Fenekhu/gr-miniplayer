import 'package:flutter/material.dart';
import 'package:gr_miniplayer/domain/history_track.dart';
import 'package:gr_miniplayer/ui/history/history_model.dart';

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
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Column(
            spacing: 8,
            children: [
              for (HistoryTrack track in viewModel.list.reversed) 
                _TrackItem(key: Key('ht${i++}'), track: track)
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
  });

  final HistoryTrack track;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Placeholder(
          fallbackWidth: 32,
          fallbackHeight: 32,
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
            ),
          ],
        ))
      ],
    );
  }
}