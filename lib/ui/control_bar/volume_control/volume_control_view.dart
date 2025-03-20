import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/control_bar/volume_control/volume_control_model.dart';
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;

class VolumeControlView extends StatelessWidget {
  VolumeControlView({super.key, required this.viewModel});

  final VolumeControlModel viewModel;
  final MenuController _menuController = MenuController();

  void _toggleMenu() {
    _menuController.isOpen? _menuController.close() : _menuController.open();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_style.controlIconBoxSize,
      height: app_style.controlIconBoxSize,
      child: MenuAnchor(
        controller: _menuController,
        clipBehavior: Clip.none,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Color.lerp(Theme.of(context).colorScheme.surface, Colors.grey, 0.25)),
        ),
        menuChildren: [ // items in the menu
          StreamBuilder<double>(
            stream: viewModel.volumeStream, // build items based on volume value
            builder: (context, snapshot) {
              final double volume = snapshot.data ?? 1;
              return Stack( // stack to override slider's weird forced spacing at the ends.
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Container( // volume text
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text(
                      (volume*100).toStringAsFixed(0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container( // volume slider
                    margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    height: 160,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: volume, 
                        onChanged: (newVol) => viewModel.volume = newVol, // adjust player volume as you slide it
                        onChangeEnd: (newVol) => app_settings.playerVolume = newVol, // only write to persistent storage once you release slider.
                      ),
                    ),
                  ),
                ],
              );
            }
          )
        ],
        child: IconButton( // the volume button
          iconSize: app_style.controlIconSize,
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.volume_up),
          onPressed: _toggleMenu, 
        ),
      ),
    );
  }
}