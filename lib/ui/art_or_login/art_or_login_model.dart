import 'package:gr_miniplayer/data/repository/user_data.dart';

class ArtOrLoginModel {
  ArtOrLoginModel({required UserResources userResources}) :
    _userResources = userResources {
      needsLoginPageStream = _userResources.needsLoginPageStream;
    }

  final UserResources _userResources;

  late final Stream<bool> needsLoginPageStream;
}