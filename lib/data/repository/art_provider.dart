import 'dart:developer';

import 'package:flutter/material.dart';

/// Provides a cached network image or a placeholder image.
/// Exists to prevent multiple fetches of the same image when the UI is hot-reloaded.
class ArtProvider {
  static const BoxFit _imageFit = BoxFit.contain;

  ArtProvider() :
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