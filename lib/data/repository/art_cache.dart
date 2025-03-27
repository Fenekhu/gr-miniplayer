import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_miniplayer/util/lib/app_info.dart' as app_info;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Provides a cached network image or a placeholder image.
/// Exists to prevent multiple fetches of the same image when the UI is hot-reloaded
/// or when the media transport needs a URI.
class ArtCache {
  static const String _placeholderPath = 'images/placeholder-art.png';
  static const BoxFit _imageFit = BoxFit.contain;
  static final http.Client _client = http.IOClient(HttpClient()..userAgent = app_info.userAgent);

  /// returns the file of a cache copy of the asset in assets/assetPath
  // needed because there's no way to get the file path of an asset, but media transport needs a path.
  static Future<File> _cachedFromAsset(String assetPath) async {
    final file = File('${(await getTemporaryDirectory()).path}/$assetPath');
    if (await file.exists()) { // check if its already been cached
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

  /// the file that holds the downloaded/locally cached image.
  /// This future completes once the file has been created.
  final Future<File> _cachedImageFile = getApplicationCacheDirectory()
    .then((dir) => File('${dir.path}/art.jpg').create(recursive: true));

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
  Completer<void> _downloadCompleter = Completer();
  bool _downloading = false;

  late Uint8List _cachedImageData;
  /// the network url of the image that is currently cached.
  String _cachedUrl = '';

  /// downloads a file from the internet and returns its path
  Future<void> _downloadFromNetwork(String url) async {
    if (_downloading) return _downloadCompleter.future;
    _downloading = true;

    log('downloading new image ($url) to ${(await _cachedImageFile).absolute.path}', name: 'Art Cache');

    final response = await _client.get(Uri.parse(url)); // download from url
    _cachedImageData = Uint8List.fromList(response.bodyBytes); // store results in memory
    await _cachedImageFile.then((file) => file.writeAsBytes(_cachedImageData, flush: true)); // write results to file

    _downloading = false;
    _cachedUrl = url;
    _downloadCompleter.complete();
    _downloadCompleter = Completer();
  }

  /// returns the locally cached image's file, downloading it if needed. The future completes as soon as the file is available.
  Future<File> loadCachedFile(String url) async {
    if (url.isEmpty) return _placeholderArtFile;
    if (url != _cachedUrl) await _downloadFromNetwork(url);
    return _cachedImageFile;
  }

  /// returns the cached image, downloading it if needed. The future completes as soon as the image is ready.
  Future<Image> getImage(String url) async {
    if (url.isEmpty) return placeholderArt;
    if (url != _cachedUrl) await _downloadFromNetwork(url);
    return Image.memory(
      _cachedImageData,
      key: UniqueKey(),
      errorBuilder: (context, error, stackTrace) {
        log('getImage error', error: error, stackTrace: stackTrace, name: 'Art Cache');
        return placeholderArt;
      },
      fit: _imageFit,
    );
  }


  /// returns a widget that will resolve to an image once its ready.
  FutureBuilder<Image> getImageWidget(String url) {
    return FutureBuilder(
      future: getImage(url), 
      //builder: (context, snapshot) => snapshot.data ?? placeholderArt,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log('snapshot has error', error: snapshot.error, stackTrace: snapshot.stackTrace, name: 'Art Cache');
        }
        if (snapshot.data == null) log('snapshot.data is null, building placeholder', name: 'Art Cache');
        return snapshot.data ?? placeholderArt;
      },
    );
  }
}

/*
class ArtCache_old {
  static const BoxFit _imageFit = BoxFit.contain;

  ArtCache_old() :
    _placeholderArt = Image.asset('assets/images/placeholder-art.png', fit: _imageFit) {
      _cachedImage = _placeholderArt;
    }

  /// The fallback art to use if the image fails to load.
  final Image _placeholderArt;

  late Image _cachedImage;
  String _cachedImagePath = '';

  /// Loads and caches the given network URL path.
  /// Pass an empty string to get the placeholder art.
  /// Will also return placeholder art if loading fails.
  Image get(String path) {
    // if the image to load is not the same as the cached one, update the cache
    if (path != _cachedImagePath) {
      log('loading new image: $path', name: 'Art Provider');
      _cachedImagePath = path;
      _cachedImage = _cachedImagePath.isEmpty? // early check for empty string
        _placeholderArt // placeholder if empty
        :
        Image.network( // otherwise load the new image
          _cachedImagePath,
          fit: _imageFit,
          errorBuilder: (context, error, stackTrace) => _placeholderArt, // the widget to display (placeholder art) if the image fails to load (invalid url, etc).
        );
    }
    
    return _cachedImage;
  }
}
*/