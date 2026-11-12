import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AzkarAudioManager {
  static const String _folderName = 'azkar_offline_pack';

  /// الروابط الرسمية لحزمة الأوفلاين للشيخ مشاري بن راشد العفاسي
  static const Map<String, String> defaultOfflineUrls = {
    'morning': 'https://archive.org/download/AZKAR_MICHARY/sabah_for_mobile.mp3',
    'evening': 'https://archive.org/download/AZKAR_MICHARY/masaa_for_mobile.mp3',
  };

  /// مسار مجلد تخزين الصوتيات محلياً على الهاتف
  static Future<Directory> getAudioDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docsDir.path}/$_folderName');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// مسار الملف المحلي إن وُجد
  static Future<File?> getLocalAudioFile(String key) async {
    try {
      final dir = await getAudioDirectory();
      final file = File('${dir.path}/$key.mp3');
      if (await file.exists() && await file.length() > 10000) {
        return file;
      }
    } catch (e) {
      debugPrint('Error checking local audio file: $e');
    }
    return null;
  }

  /// هل تتوفر حزمة الأذكار الأساسية محلياً بدون إنترنت؟
  static Future<bool> isOfflinePackDownloaded() async {
    try {
      for (final key in defaultOfflineUrls.keys) {
        final file = await getLocalAudioFile(key);
        if (file == null) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// حساب الحجم الإجمالي للملفات المحملة بالميجابايت
  static Future<double> getDownloadedSizeMb() async {
    try {
      final dir = await getAudioDirectory();
      if (!await dir.exists()) return 0.0;
      int totalBytes = 0;
      await for (final file in dir.list(recursive: false)) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
      return totalBytes / (1024 * 1024);
    } catch (_) {
      return 0.0;
    }
  }

  /// حذف الحزمة لتوفير مساحة التخزين
  static Future<void> deleteOfflinePack() async {
    try {
      final dir = await getAudioDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting offline pack: $e');
    }
  }

  /// تحميل ملف صوتي وحفظه محلياً
  static Future<File?> downloadFile(
    String url,
    String key, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await getAudioDirectory();
      final targetFile = File('${dir.path}/$key.mp3');
      final tempFile = File('${dir.path}/$key.tmp');

      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'Mozilla/5.0 (SakanAlRooh/Flutter)');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException('Failed to download: status ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      int downloadedBytes = 0;

      final sink = tempFile.openWrite();
      await response.listen((chunk) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloadedBytes / contentLength);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return targetFile;
    } catch (e) {
      debugPrint('Download error for $key: $e');
      return null;
    }
  }

  /// تحميل كامل الحزمة الأساسية (أذكار الصباح والمساء)
  static Future<bool> downloadCorePack({
    void Function(String currentKey, double progress)? onProgress,
  }) async {
    try {
      int index = 0;
      final total = defaultOfflineUrls.length;

      for (final entry in defaultOfflineUrls.entries) {
        final success = await downloadFile(
          entry.value,
          entry.key,
          onProgress: (prog) {
            if (onProgress != null) {
              final overall = (index + prog) / total;
              onProgress(entry.key, overall);
            }
          },
        );
        if (success == null) return false;
        index++;
      }
      return true;
    } catch (e) {
      debugPrint('Core pack download error: $e');
      return false;
    }
  }

  /// الحصول على مصدر الصوت الجاهز للتشغيل (إما محلي أو رابط سحابي)
  static Future<String> getPlayableSource(String category, String fallbackUrl) async {
    final local = await getLocalAudioFile(category);
    if (local != null) {
      return local.path;
    }
    return fallbackUrl;
  }
}
