import 'package:flutter/foundation.dart';
import 'package:gr_miniplayer/data/repository/song_info_repo.dart';
import 'package:gr_miniplayer/domain/song_info.dart';

String _formatSeconds(int seconds) {
  final minutes = (seconds ~/ 60).toString();
  final seconds_ = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds_';
}

class ProgressStatus {
  final String elapsed;
  final String total;
  final double value;

  const ProgressStatus({required this.elapsed, required this.total, required this.value});
}

class InfoDisplayModel extends ChangeNotifier {
  InfoDisplayModel({
    required SongInfoRepo songInfoRepo
  }): _songInfoRepo = songInfoRepo {
    _songInfoRepo.infoStream.listen(_onSongInfo);

    progressStream = Stream<ProgressStatus>.periodic(
      Duration(seconds: 1),
      (tick) {
        final ret = ProgressStatus(
          elapsed: _formatSeconds(_played), 
          total: _duration <= 0? '--:--' : _formatSeconds(_duration), 
          value: _duration <= 0? 0.5 : clampDouble(_played / _duration, 0, 1),
        );
        _played++;
        return ret;
      }
    );
  }

  final SongInfoRepo _songInfoRepo;

  int _duration = 0;
  int _played = 0;

  late final Stream<ProgressStatus> progressStream;

  String title = '(no info)';
  String albumCircle = '(no info)';

  void _onSongInfo(SongInfo info) {
    title = info.title;
    albumCircle = "${info.album}    —    ${info.circle}";
    _duration = info.duration;
    _played = info.played;
    updateInfo();
  }

  void updateInfo() {
    notifyListeners();
  }
}