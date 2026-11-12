// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QuranCardGeneratorService {
  /// Captures a widget wrapped with a RepaintBoundary and exports it as a PNG File
  static Future<File?> captureAndSaveWidget(GlobalKey boundaryKey, {String filename = 'sakan_al_rooh_card.png'}) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Higher pixelRatio for crisp Ultra-HD output (ideal for WhatsApp stories)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('Error capturing card image: $e');
      return null;
    }
  }

  /// Shares the captured image directly to WhatsApp / Social media
  static Future<bool> shareCardImage(GlobalKey boundaryKey, {String caption = 'تطبيق سكن الروح (Sakan Al-Rooh): صدقة جارية 🌿'}) async {
    try {
      final file = await captureAndSaveWidget(boundaryKey);
      if (file != null && await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: caption,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sharing card image: $e');
      return false;
    }
  }
}
