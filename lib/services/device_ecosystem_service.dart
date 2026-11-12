import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// بيئة النظام أو المتجر المشغل للتطبيق
enum DeviceEcosystem {
  apple,  // أجهزة Apple (iOS / iPadOS)
  huawei, // أجهزة Huawei / Honor (HMS)
  google, // أجهزة Android العامة المزودة بخدمات Google Play
}

/// خدمة ذكية تكتشف بيئة نظام التشغيل والشركة المصنعة عند إقلاع التطبيق
class DeviceEcosystemService {
  static final DeviceEcosystemService _instance = DeviceEcosystemService._internal();
  factory DeviceEcosystemService() => _instance;
  DeviceEcosystemService._internal();

  static const MethodChannel _channel = MethodChannel('com.nooralhoda.official.app/device_ecosystem');

  DeviceEcosystem _ecosystem = DeviceEcosystem.google;
  bool _initialized = false;

  DeviceEcosystem get currentEcosystem => _ecosystem;
  bool get isApple => _ecosystem == DeviceEcosystem.apple;
  bool get isHuawei => _ecosystem == DeviceEcosystem.huawei;
  bool get isGoogle => _ecosystem == DeviceEcosystem.google;

  /// تهيئة واكتشاف النظام عند بدء تشغيل التطبيق
  Future<DeviceEcosystem> initialize() async {
    if (_initialized) return _ecosystem;

    try {
      if (kIsWeb) {
        _ecosystem = DeviceEcosystem.google;
      } else if (Platform.isIOS || Platform.isMacOS) {
        _ecosystem = DeviceEcosystem.apple;
      } else if (Platform.isAndroid) {
        try {
          final String? result = await _channel.invokeMethod<String>('getDeviceEcosystem');
          if (result == 'huawei') {
            _ecosystem = DeviceEcosystem.huawei;
          } else {
            _ecosystem = DeviceEcosystem.google;
          }
        } catch (e) {
          debugPrint('DeviceEcosystemService: Native channel not ready, fallback to Google: $e');
          _ecosystem = DeviceEcosystem.google;
        }
      } else {
        _ecosystem = DeviceEcosystem.google;
      }
    } catch (e) {
      debugPrint('DeviceEcosystemService: Detection error: $e');
      _ecosystem = DeviceEcosystem.google;
    }

    _initialized = true;
    debugPrint('DeviceEcosystemService: Detected ecosystem -> ${_ecosystem.name.toUpperCase()}');
    return _ecosystem;
  }
}
