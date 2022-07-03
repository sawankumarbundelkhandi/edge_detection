import 'dart:async';

import 'package:flutter/services.dart';

class EdgeDetection {
  static const MethodChannel _channel = const MethodChannel('edge_detection');

  static Future<String?> get detectEdge async {
    final String? imagePath = await _channel.invokeMethod('edge_detect');
    return imagePath;
  }
  static Future<String?> get detectEdgeFromGallery async {
    final String? imagePath = await _channel.invokeMethod('edge_detect_gallery');
    return imagePath;
  }
}
