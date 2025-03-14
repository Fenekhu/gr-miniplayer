import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/control_bar/volume_control/volume_control_model.dart';
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;

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
      width: 32,
      height: 32,
      child: MenuAnchor(
        controller: _menuController,
        clipBehavior: Clip.none,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Color.lerp(Theme.of(context).colorScheme.surface, Colors.grey, 0.25)),
        ),
        menuChildren: [
          StreamBuilder<double>(
            stream: viewModel.volumeStream,
            builder: (context, snapshot) {
              final double volume = snapshot.data ?? 1;
              return Stack(
                children: [
                  Container(
                    width: 32,
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      (volume*100).toStringAsFixed(0),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Slider.adaptive(
                      value: volume, 
                      onChanged: (newVol) => viewModel.volume = newVol,
                      onChangeEnd: (newVol) => app_settings.playerVolume = newVol,
                    ),
                  ),
                ],
              );
            }
          )
        ],
        child: IconButton(
          iconSize: 32,
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.volume_up),
          onPressed: _toggleMenu, 
        ),
      ),
    );
  }
}