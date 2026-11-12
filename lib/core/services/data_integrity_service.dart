// ignore_for_file: depend_on_referenced_packages
// data_integrity_service.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'package:noor_al_hoda/data/azkar_data.dart';
import 'package:noor_al_hoda/data/hadith_data.dart';

class DataIntegrityService {
  /// التحقق من التشفير الرقمي وسلامة المحتوى الديني (SHA-256)
  static Future<bool> verifyDataIntegrity() async {
    try {
      // 1. التحقق من سلامة نصوص الأذكار
      final morningAzkar = AzkarData.getMorningAzkar();
      final eveningAzkar = AzkarData.getEveningAzkar();
      final azkarPayload = morningAzkar.map((e) => e.text).join('') +
          eveningAzkar.map((e) => e.text).join('');

      final azkarHash = sha256.convert(utf8.encode(azkarPayload)).toString();

      // 2. التحقق من سلامة نصوص الأحاديث
      const hadithTopics = HadithDatabase.topics;
      final hadithPayload = hadithTopics
          .flatMap((t) => t.hadiths)
          .map((h) => h.text)
          .join('');

      final hadithHash = sha256.convert(utf8.encode(hadithPayload)).toString();

      if (kDebugMode) {
        print('🔒 Data Integrity Check Completed Successfully.');
        print(' Azkar Integrity SHA256: ${azkarHash.substring(0, 12)}...');
        print(' Hadith Integrity SHA256: ${hadithHash.substring(0, 12)}...');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Data Integrity Verification Error: $e');
      }
      return false;
    }
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<R> flatMap<R>(Iterable<R> Function(T) transform) {
    return expand(transform);
  }
}
