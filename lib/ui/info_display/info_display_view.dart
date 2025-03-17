import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/info_display/info_display_model.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;
import 'package:marquee/marquee.dart';

bool _willTextOverflow({required String text, required TextStyle style, required double maxWidth}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: maxWidth);

  return textPainter.didExceedMaxLines;
}

class _MyMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double maxWidth;
  const _MyMarquee({required this.text, required this.style, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return _willTextOverflow(text: text, style: style, maxWidth: maxWidth)?
      Marquee(
        text: text,
        blankSpace: app_style.marqueeBlankWidth,
        pauseAfterRound: const Duration(seconds: 10),
        startAfter: const Duration(seconds: 10),
        showFadingOnlyWhenScrolling: false,
        velocity: 16,
        style: style,
      )
      :
      Text(text, style: style, maxLines: 1, textAlign: TextAlign.center,);
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
        ListenableBuilder(
          listenable: viewModel, 
          builder: (context, _) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: _MyMarquee(
                        text: viewModel.title, 
                        style: app_style.songTitleStyle, 
                        maxWidth: constraints.maxWidth,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: _MyMarquee(
                        text: viewModel.albumCircle, 
                        style: app_style.otherInfoStyle, 
                        maxWidth: constraints.maxWidth,
                      ),
                    ),
                  ],
                );
              },
            );
          }
        ),
        StreamBuilder<ProgressStatus>(
          stream: viewModel.progressStream,
          builder: (context, snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Text(snapshot.data?.elapsed ?? '--:--'),
                Expanded(
                  child: LinearProgressIndicator(
                    value: snapshot.data?.value ?? 0.5,
                    backgroundColor: colors.onSurface.withAlpha(127),
                    color: colors.onSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(snapshot.data?.total ?? '--:--'),
              ],
            );
          }
        ),
      ],
    );
  }
}