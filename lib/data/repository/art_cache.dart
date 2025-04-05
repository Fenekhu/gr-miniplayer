import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_miniplayer/util/exceptions.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:gr_miniplayer/util/lib/app_settings.dart' as app_settings;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Provides a cached network image or a placeholder image.
/// Exists to prevent multiple fetches of the same image when the UI is hot-reloaded
/// or when the media transport needs a URI.
class ArtCache {
  static const String _placeholderPath = 'images/icon.png';
  static const BoxFit _imageFit = BoxFit.contain;
  static final http.Client _client = http.IOClient(HttpClient()..userAgent = app_info.userAgent);

  /// returns the file of a cache copy of the asset in assets/assetPath
  // needed because there's no way to get the file path of an asset, but media transport needs a path.
  static Future<File> _cachedFromAsset(String assetPath) async {
    final file = File(path.join((await getApplicationCacheDirectory()).path, assetPath));
    if (file.existsSync()) { // check if its already been cached
      return file;
    } else { // otherwise, load its raw asset bytes and store them in a new file (whose path is now accessible)
      final bytes = await rootBundle.load('assets/$assetPath');
      return file.create(recursive: true)
        .then((file) => file.writeAsBytes(Uint8List.sublistView(bytes), flush: true));
    }
  }

  

  ArtCache() :
    placeholderArt = Image.asset('assets/$_placeholderPath', fit: _imageFit),
    _placeholderArtFile = _cachedFromAsset(_placeholderPath);

  final Future<File> _placeholderArtFile; // needed for media transport, because assets cant be converted directly to paths.
  final Image placeholderArt;
  Future<Uri> get placeholderArtUri async => (await _placeholderArtFile).absolute.uri; // needed for media transport

  // I was running into an asyncronous data race and needed this to fix it.
  // Both the UI and media transport try to get the current art at the same time when info is received. (The UI usually second).
  // the `url == _cachedUrl` checks were meant to handle this, but depending on whether _cachedUrl updated before or after downloading:
  // before: the call to getImage would see `_cachedUrl == url`, thus skipping download. However, it was still downloading in progress,
  //   causing _cachedImageData to be not-yet-set, and creating the image would fail on the first time, or be outdated.
  // after: the call to getImage would see `_cachedUrl != url` and initiate a second download when one was already in progress,
  //   entirely defeating the point of caching the result.
  // The solution was to set a `_downloading` flag to true for the duration of the download, and avoid any further downloads while one is in progress.
  // But wait, everything awaits _downloadFromNetwork to complete its future to know when its done downloading.
  // If I early return, the 'before' issue happens again, where it will think its finished downloading when it hasn't.
  // Luckily Dart provides a thing called a `Completer` which I don't really understand well enough to explain,
  // but it allows me to return the same future from the first call for all overlapping calls, then complete that one future when the first one finishes.
  // UPDATE: The flag was replaced by making the completer nullable - completer will only be non-null when downloading [is true].
  // UPDATE: Every image is now cached separately. There needs to be a completer for each file.

  // A map to filename to the completer when multiple separate thumbnails are being downloaded simultaneously.
  // ie <'_75896f85ef.jpg', ...>
  final Map<String, Completer<File>> _completers = {};

  /// Get the file for an ID. File may or may not exist. Does not download anything.
  Future<File> _getFileForID(String id) async {
    return getApplicationCacheDirectory().then((dir) => File(path.join(dir.path, 'art', id)));
  }

  /// downloads an image to the cache if it isn't already there (or optionally force it to download anyway).
  Future<File> _maybeDownloadImage(String url, {bool force = false}) async {
    // id: the filename like '_75896f85ef.jpg'
    final id = path.basename(url);

    // If the completer exists (true if it is currently or already has downloaded), return its future.
    // this needs to be checked before checking the file exists to prevent returning an empty file while the image is still downloading.
    if (_completers[id] != null) return _completers[id]!.future;

    // gr-logo-placeholder.png is at a different url base than album images.
    // To be consistent, I'm going to replace references to it with our placeholder.
    if (id.isEmpty || id == 'gr-logo-placeholder.png') {
      return _placeholderArtFile;
    }

    // update the status as we start to download the requested image.
    _completers[id] = Completer();

    final file = await _getFileForID(id);
    final fileExists = file.existsSync();
    // if the file exists and we aren't going to force a download, return the file.
    if (fileExists && !force) {
      _completers[id]!.complete(file);
      _completers.remove(id);
      return file;
    }
    // otherwise continue on with downloading.

    log('downloading new image to ${file.absolute.path}', name: 'Art Cache');

    try {
      final uri = Uri.parse('https://gensokyoradio.net/images/albums/${app_settings.artQuality.value}/$id'); // Note: not all images seem to be available at all qualities, especially lower ones.
      final response = await _client.get(uri); // download from url
      
      // data should only be saved after a successful fetch to prevent creating an empty file.
      if (response.statusCode == 200) {
        // create the file if it doesn't exist.
        if (!fileExists) file.create(recursive: true);
        file.writeAsBytesSync(response.bodyBytes, flush: true); // write results to file
      } else { // otherwise return placeholder art.
        log('bad response fetching art', error: BadResponseCodeException(response), name: 'Art Cache');
        return _placeholderArtFile;
      }
    } finally {
      // the completer needs to reset if something goes wrong, otherwise the future will never release.
      _completers[id]!.complete(file);
      _completers.remove(id);
    }

    return file;
  }

  /// returns the locally cached image's file, downloading it if needed. The future completes as soon as the file is available.
  Future<File> getImageFile(String url) => _maybeDownloadImage(url);

  /// returns the cached image, downloading it if needed. The future completes as soon as the image is ready.
  Future<Image> getImage(String url) async {
    return Image.file(
      await _maybeDownloadImage(url),
      fit: _imageFit,
      errorBuilder: (context, error, stackTrace) {
        log('getImage error', error: error, stackTrace: stackTrace, name: 'Art Cache');
        return placeholderArt;
      },
    );
  }

  /// returns a widget that will resolve to an image once its ready.
  FutureBuilder<Image> getImageWidget(String url) {
    return FutureBuilder(
      future: getImage(url), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('image snapshot has error', error: snapshot.error, stackTrace: snapshot.stackTrace, name: 'Art Cache'); 
        }
        if (snapshot.data == null) log('image snapshot.data is null, building placeholder', name: 'Art Cache');
        return snapshot.data ?? placeholderArt;
      },
    );
  }
}

