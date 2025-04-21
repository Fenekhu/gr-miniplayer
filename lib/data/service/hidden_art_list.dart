import 'dart:async';
import 'dart:io';

import 'package:gr_miniplayer/domain/player_info.dart';
import 'package:path_provider/path_provider.dart';

/// wraps and caches the file that stores the list of albums who's art should be hidden.
class HiddenArtList {
  final StreamController<ArtHidingStatus> _artHidingUpdatesController = StreamController.broadcast();

  Stream<ArtHidingStatus> get artHidingStatusStream => _artHidingUpdatesController.stream;

  Set<String>? _cachedList;

  Future<File> get _file async {
    final path = (await getApplicationSupportDirectory()).path;
    return File('$path/hidden_art.txt');
  }

  /// The list of albumIDs
  Future<Set<String>> get list async {
    if (_cachedList == null) {
      final file = await _file;
      await file.create(); // creates the file if it doesn't exist, because...
      final contents = await file.readAsLines(); // this needs the file to exist.
      _cachedList = Set.from(contents);
    }
    return _cachedList!;
  }

  /// Writes the current list to disk. 
  Future<File> _write() async {
    final contents = (await list).join('\n'); // join the list as one albumID per line
    return (await _file).writeAsString(contents);
  }

  Future<void> dispose() async {
    await _artHidingUpdatesController.close();
  }

  /// see dart Set.contains
  Future<bool> contains(String albumID) async {
    if (albumID == '0') return false; // never hide undefined art.
    return (await list).contains(albumID);
  }

  /// emits the art hiding status for a given song to the artHidingStatusStream
  void emitFor(String albumID) {
    contains(albumID).then((value) => _artHidingUpdatesController.add(ArtHidingStatus(albumID, value)));
  }

  /// see dart Set.add
  Future<void> add(String albumID) async {
    if ((await list).add(albumID)) { // if changes were actually made to the list
      _artHidingUpdatesController.add(ArtHidingStatus(albumID, true)); // emit stream event
      await _write(); // write changes to disk
    }
  }

  /// see dart Set.remove
  Future<void> remove(String albumID) async {
    if ((await list).remove(albumID)) { // if changes were actually made to the list
      _artHidingUpdatesController.add(ArtHidingStatus(albumID, false)); // emit stream event
      await _write(); // write changes to disk
    }
  }
}