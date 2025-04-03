import 'dart:async';

import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

class InfoDisplayModel {
  InfoDisplayModel({required SongInfoRepo songInfoRepo}) : 
    _songInfoRepo = songInfoRepo;

  final SongInfoRepo _songInfoRepo;

  SongInfo? get latestInfo => _songInfoRepo.latestInfo;
  Stream<SongInfo> get infoStream => _songInfoRepo.infoStream;
  Stream<ProgressStatus> get progressStream => _songInfoRepo.progressStream;
}