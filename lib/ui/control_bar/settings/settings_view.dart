import 'package:flutter/material.dart';
import 'package:gr_miniplayer/ui/control_bar/settings/settings_model.dart';
import 'package:gr_miniplayer/util/enum/stream_endpoint.dart';
import 'package:gr_miniplayer/util/lib/app_style.dart' as app_style;
import 'package:gr_miniplayer/util/lib/window_utils.dart' as window_utils;
import 'package:url_launcher/url_launcher.dart';

class SettingsMenuView extends StatelessWidget {
  SettingsMenuView({super.key, required this.viewModel});

  final SettingsMenuModel viewModel;
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
        menuChildren: [
          MenuItemButton(
            onPressed: () async => await launchUrl(Uri.parse("https://www.gensokyoradio.net/")),
            child: Row(
              spacing: 4,
              children: [
                SizedBox(
                  width: app_style.menuIconBoxSize,
                  height: app_style.menuIconBoxSize,
                  child: const Icon(Icons.open_in_new, size: app_style.menuIconSize),
                ),
                Text("gensokyoradio.net"),
              ],
            ),
          ),
          _DividerWithText("Quality"),
          for (StreamEndpoint ep in StreamEndpoint.values) _StreamSourceItem(viewModel: viewModel, endpoint: ep),
          Divider(
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          MenuItemButton(
            onPressed: window_utils.resetWindowSize,
            child: Text("Reset Window Size"),
          ),
        ],
        child: IconButton(
          iconSize: app_style.controlIconSize,
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.more_horiz),
          onPressed: _toggleMenu,
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(
          indent: 8,
          endIndent: 8,
          color: Colors.grey,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text),
        ),
        Expanded(child: Divider(
          indent: 8,
          endIndent: 8,
          color: Colors.grey,
        )),
      ],
    );
  }
}

class _CheckableText extends StatelessWidget {
  final String text;
  final bool checked;
  const _CheckableText({super.key, required this.text, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        SizedBox(
          width: app_style.menuIconBoxSize,
          height: app_style.menuIconBoxSize,
          child: checked? const Icon(Icons.check, size: app_style.menuIconSize) : null,
        ),
        Text(text),
      ],
    );
  }
}

class _StreamSourceItem extends StatelessWidget {
  final StreamEndpoint endpoint;
  final SettingsMenuModel viewModel;

  const _StreamSourceItem({super.key, required this.endpoint, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: () => viewModel.endpoint = endpoint,
      child: _CheckableText(
        text: endpoint.name, 
        checked: endpoint == viewModel.endpoint,
      ),
    );
  }
}