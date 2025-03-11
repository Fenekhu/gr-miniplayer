import 'package:gr_miniplayer/data/service/hidden_art_list.dart';

class HiddenArtManager {
  HiddenArtManager({required HiddenArtList listService})
    : _listService = listService;

  final HiddenArtList _listService;

  Future<bool> contains(String albumID) async {
    return (await _listService.list).contains(albumID);
  }

  Future<void> add(String albumID, {bool write = true}) async {
    (await _listService.list).add(albumID);
    if (write) await _listService.write();
  }

  Future<void> remove(String albumID, {bool write = true}) async {
    (await _listService.list).remove(albumID);
    if (write) await _listService.write();
  }
}