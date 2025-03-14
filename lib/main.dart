import 'package:flutter/material.dart';
import 'package:gr_miniplayer/data/repository/audio_player.dart';
import 'package:gr_miniplayer/data/repository/hidden_art_manager.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/data/repository/user_data.dart';
import 'package:gr_miniplayer/data/service/hidden_art_list.dart';
import 'package:gr_miniplayer/data/service/info_websocket.dart';
import 'package:gr_miniplayer/data/service/station_api.dart';
import 'package:gr_miniplayer/domain/player_state.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_model.dart';
import 'package:gr_miniplayer/ui/art_display/art_display_view.dart';
import 'package:gr_miniplayer/ui/control_bar/control_bar_view.dart';
import 'package:gr_miniplayer/ui/window_controls.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/shared_prefs.dart';
import 'package:gr_miniplayer/util/lib/window_utils.dart' as window_utils;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await shared_prefs.ensureInitialized();
  await AudioPlayer.ensureInitialized();
  await window_utils.setupWindow();

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => StationApiClient(),
          dispose: (context, value) => value.dispose(),
        ),
        Provider(
          create: (context) => InfoWebsocket(),
          dispose: (context, value) => value.dispose(),
        ),
        Provider(create: (context) => HiddenArtList()),

        Provider(create: (context) => UserResources(
          apiClient: context.read(),
        )),
        Provider(create: (context) => SongInfoRepo(
          infoWebsocket: context.read(), 
          hiddenArtList: context.read(),
        )),
        Provider(create: (context) => HiddenArtManager(
          listService: HiddenArtList(),
        )),
        Provider(
          create: (context) => AudioPlayer(),
          dispose: (context, value) => value.dispose(),
        ),

        Provider(create: (context) => PlayerStateCoordinator(
          audioPlayer: context.read(), 
          songInfoRepo: context.read(),
        ),)
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: app_info.name,
      theme: ThemeData.from(colorScheme: const ColorScheme.light()),
      darkTheme: ThemeData.from(colorScheme: const ColorScheme.dark()),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SongInfoRepo>().connect(retryDelay: null));
    context.read<PlayerStateCoordinator>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              DragToMoveArea(
                child: ArtDisplayView(
                  viewModel: ArtDisplayModel(
                    hiddenArtManager: context.read(), 
                    songInfoRepo: context.read(),
                  )
                ),
              ),
              SizedBox(height: 8),
              ControlBar(),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: WindowControls(),
          ),
        ],
      ),
    );
  }
}
