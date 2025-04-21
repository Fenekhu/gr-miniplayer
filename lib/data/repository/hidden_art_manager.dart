import 'package:gr_miniplayer/data/service/hidden_art_list.dart';
import 'package:gr_miniplayer/domain/player_info.dart';

/// CRUD operations wrapping the list of album IDs who's art should be hidden.
class HiddenArtManager {
  HiddenArtManager({required HiddenArtList listService})
    : _listService = listService;

  final HiddenArtList _listService;
  Stream<ArtHidingStatus> get artHidingStatusStream => _listService.artHidingStatusStream;

  /// see dart Set.contains
  Future<bool> contains(String albumID) => _listService.contains(albumID);

  /// emits the art hiding status for a given song to the artHidingStatusStream
  void emitFor(String albumID) => _listService.emitFor(albumID);

  /// hides the art and emits an event to the stream.
  /// does nothing if the art is already hidden.
  Future<void> hide(String albumID) => _listService.add(albumID);

  /// shows the art and emits an event to the stream.
  /// does nothing of the art is already shown.
  Future<void> show(String albumID) => _listService.remove(albumID);

  /// toggles the art's visibility and emits an event to the stream.
  Future<void> toggle(String albumID) async => (await _listService.contains(albumID))? show(albumID) : hide(albumID);

  
}