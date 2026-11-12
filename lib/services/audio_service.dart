import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  static final AudioPlayer player = AudioPlayer();
  static String? currentUrl;
  static double currentSpeed = 1.0;
  static bool _sessionInitialized = false;

  static Future<void> _initAudioSession() async {
    if (_sessionInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _sessionInitialized = true;
    } catch (e) {
      debugPrint('AudioSession init error: $e');
    }
  }

  static Future<void> play(String url) async {
    try {
      await _initAudioSession();
      if (currentUrl == url && player.processingState != ProcessingState.completed) {
        if (!player.playing) {
          await player.play();
        }
        return;
      }
      currentUrl = url;
      await player.stop();
      if (url.startsWith('assets/')) {
        await player.setAsset(url);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        await player.setUrl(url);
      } else {
        await player.setFilePath(url);
      }
      await player.setSpeed(currentSpeed);
      await player.play();
    } catch (e) {
      debugPrint('AudioService play error: $e');
      currentUrl = null;
      rethrow;
    }
  }

  static Future<void> pause() async {
    await player.pause();
  }

  static Future<void> resume() async {
    await player.play();
  }

  static Future<void> stop() async {
    currentUrl = null;
    await player.stop();
  }

  static Future<void> setSpeed(double speed) async {
    currentSpeed = speed;
    await player.setSpeed(speed);
  }

  static Future<void> seekForward({int seconds = 10}) async {
    final currentPos = player.position;
    final newPos = currentPos + Duration(seconds: seconds);
    final duration = player.duration ?? Duration.zero;
    if (newPos < duration) {
      await player.seek(newPos);
    } else {
      await player.seek(duration);
    }
  }

  static Future<void> seekBackward({int seconds = 10}) async {
    final currentPos = player.position;
    final newPos = currentPos - Duration(seconds: seconds);
    if (newPos > Duration.zero) {
      await player.seek(newPos);
    } else {
      await player.seek(Duration.zero);
    }
  }

  static Future<void> seek(Duration duration) async {
    await player.seek(duration);
  }

  static Stream<Duration> get positionStream => player.positionStream;
  static Stream<Duration?> get durationStream => player.durationStream;
  static Stream<bool> get playingStream => player.playingStream;
  static Stream<ProcessingState> get processingStateStream => player.processingStateStream;

  static Future<void> dispose() async {
    try {
      await player.dispose();
    } catch (_) {}
  }
}

