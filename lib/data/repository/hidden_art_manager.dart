import 'package:gr_miniplayer/data/service/hidden_art_list.dart';

/// CRUD operations wrapping the list of album IDs who's art should be hidden.
class HiddenArtManager {
  HiddenArtManager({required HiddenArtList listService})
    : _listService = listService;

  final HiddenArtList _listService;

  /// see dart Set.contains
  Future<bool> contains(String albumID) async {
    return (await _listService.list).contains(albumID);
  }

  /// see dart Set.add
  Future<void> add(String albumID, {bool write = true}) async {
    (await _listService.list).add(albumID);
    if (write) await _listService.write(); // write changes to disk
  }

  /// see dart Set.remove
  Future<void> remove(String albumID, {bool write = true}) async {
    (await _listService.list).remove(albumID);
    if (write) await _listService.write(); // write changes to disk
  }
}