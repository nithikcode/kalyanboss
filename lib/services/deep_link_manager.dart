import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:rxdart/rxdart.dart'; // Import rxdart

class DeepLinkManager {
  // Singleton
  static final DeepLinkManager _instance = DeepLinkManager._internal();
  factory DeepLinkManager() => _instance;
  DeepLinkManager._internal();

  // Replace StreamController with BehaviorSubject
  final _linkStreamController = BehaviorSubject<Uri>();

  /// Stream for any widget to listen to deep links
  Stream<Uri> get linkStream => _linkStreamController.stream;

  final AppLinks _appLinks = AppLinks();

  /// Initialize deep links
  void init() async {
    // Handle cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _linkStreamController.add(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial app link: $e');
    }

    // Listen to incoming app links while app is running
    _appLinks.uriLinkStream.listen(
          (Uri? uri) {
        if (uri != null) _linkStreamController.add(uri);
      },
      onError: (err) => debugPrint('Deep link stream error: $err'),
    );
  }

  /// Dispose listener
  void dispose() {
    // Note: BehaviorSubject does not have a cancel method on the subject itself.
    // The subscription in BasePage will be cancelled.
    _linkStreamController.close();
  }

  /// Helper: Extract product slug from URI
  String? getProductSlug(Uri uri) {
    if (uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'product' &&
        uri.pathSegments.length > 1) {
      final slugSegments = uri.pathSegments.sublist(1);
      return slugSegments.join('/');
    }
    return null;
  }
}

