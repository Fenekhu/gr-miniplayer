import 'dart:developer';

import 'package:flutter/material.dart';

class ArtProvider {
  static const BoxFit _imageFit = BoxFit.contain;

  ArtProvider() :
    _placeholderArt = Image.asset('assets/images/placeholder-art.png', fit: _imageFit) {
      _cachedImage = _placeholderArt;
    }

  
  final Image _placeholderArt;

  late Image _cachedImage;
  String _cachedImagePath = '';

  Image load(String path) {
    if (path != _cachedImagePath) {
      log('loading new image: $path', name: 'Art Provider');
      _cachedImagePath = path;
      _cachedImage = _cachedImagePath.isEmpty? 
        _placeholderArt
        :
        Image.network(
          _cachedImagePath,
          fit: _imageFit,
          errorBuilder: (context, error, stackTrace) => _placeholderArt,
        );
    }
    
    return _cachedImage;
  }
}