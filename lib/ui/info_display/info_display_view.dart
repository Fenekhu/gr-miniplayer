import 'package:flutter/material.dart';
import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;
import 'package:marquee/marquee.dart';

/// for calculating whether or not text will need to be in a marquee
bool _willTextOverflow({required String text, required TextStyle style, required double maxWidth}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.didExceedMaxLines;
}

String _formatAlbumCircleInfo(SongInfo? info) {
  if (info == null || (info.album.isEmpty && info.circle.isEmpty)) {
    return '—';
  }
  final album = info.album.isEmpty? '(unknown album)' : info.album;
  final circle = info.circle.isEmpty? '(unknown circle)' : info.circle;
  return'$album    —    $circle';
}

/// Like a marquee, but acts as regular text if the text fits within the space.
class _MyMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _MyMarquee({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _willTextOverflow(text: text, style: style, maxWidth: constraints.maxWidth)?
          Marquee( // marquee if text overflows given space
            text: text,
            blankSpace: app_style.marqueeBlankWidth,
            pauseAfterRound: const Duration(seconds: 10),
            startAfter: const Duration(seconds: 10),
            showFadingOnlyWhenScrolling: false,
            velocity: 16,
            style: style,
          )
          : // otherwise text
          Text(
            text, 
            style: style, 
            maxLines: 1, 
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
      },
    );
  }
}

class InfoDisplayView extends StatelessWidget {
  const InfoDisplayView({super.key, required this.viewModel});

  final InfoDisplayModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StreamBuilder<SongInfo>(
          stream: viewModel.infoStream, // build text based on song info stream
          builder: (context, snapshot) {
            final data = snapshot.data ?? viewModel.latestInfo;
            final title = (data?.title == null || data!.title.isEmpty) ? '(no info)' : data.title;
            final bottomText = _formatAlbumCircleInfo(data);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 0,
              children: [
                SizedBox( // Title text
                  height: 20,
                  child: _MyMarquee(
                    text: title, 
                    style: app_style.songTitleStyle, 
                  ),
                ),
                SizedBox( // album -- circle text
                  height: 20,
                  child: _MyMarquee(
                    text: bottomText, 
                    style: app_style.otherInfoStyle, 
                  ),
                ),
              ],
            );
          }
        ),
        StreamBuilder<ProgressStatus>(
          stream: viewModel.progressStream, // build progress bar from progress stream
          builder: (context, snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Text(snapshot.data?.elapsed ?? '--:--'), // elapsed
                Expanded(
                  child: LinearProgressIndicator( // bar
                    value: snapshot.data?.value ?? 0.5,
                    backgroundColor: colors.onSurface.withAlpha(127),
                    color: colors.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(snapshot.data?.total ?? '--:--'), // duration
              ],
            );
          }
        ),
      ],
    );
  }
}