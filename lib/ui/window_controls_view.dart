import 'package:flutter/material.dart';
import 'package:gr_miniplayer/util/lib/window_utils.dart' as window_utils;

/// The minimize and close buttons
// note that this needs no model, their functionality is provided entirely by window_utils.
class WindowControlsView extends StatelessWidget {
  const WindowControlsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Row(
        children: [
          SizedBox( // minimize button
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(
                Icons.minimize, 
                color: Colors.white
              ),
              iconSize: 16,
              padding: const EdgeInsets.all(0),
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  LinearBorder(), // hover highlight fills the whole square
                ),
              ),
              onPressed: () => window_utils.minimize(),
            ),
          ),
          SizedBox( // close button
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(
                Icons.close, 
                color: Colors.white
              ),
              iconSize: 16,
              padding: const EdgeInsets.all(0),
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  LinearBorder(), // hover highlight fills the whole square
                ),
              ),
              onPressed: () => window_utils.close(),
            ),
          ),
        ],
      )
    );
  }
}