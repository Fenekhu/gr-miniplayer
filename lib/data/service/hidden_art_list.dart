import 'dart:io';

import 'package:path_provider/path_provider.dart';

class HiddenArtList {
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
  /// Optionally, [flush] waits for the contents to be written to resolve the future.
  Future<File> write({bool flush = false}) async {
    final contents = (await list).join('\n'); // join the list as one albumID per line
    return (await _file).writeAsString(contents, flush: flush);
  }
}