import 'package:flutter/material.dart';
import 'package:gr_miniplayer/util/lib/window_utils.dart' as window_utils;

class WindowControls extends StatelessWidget {
  const WindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Row(
        children: [
          SizedBox(
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
                  LinearBorder(),
                ),
              ),
              onPressed: () => window_utils.minimize(),
            ),
          ),
          SizedBox(
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
                  LinearBorder(),
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