// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class CustomErrorReporter {
  /// Map complex exception strings into plain, user-friendly Arabic explanations
  static String getArabicMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('invalid_sound') || 
        errorStr.contains('resource') && errorStr.contains('not be found') ||
        errorStr.contains('platformexception(invalid_sound')) {
      return 'تعذر تشغيل أو جدولة صوت الأذان (ملف athan.mp3 غير موجود أو غير مهيأ بشكل صحيح). يرجى التحقق من تثبيت ملفات الصوت في التطبيق.';
    }
    
    if (errorStr.contains('socketexception') || 
        errorStr.contains('handshake') || 
        errorStr.contains('networkimage') ||
        errorStr.contains('http')) {
      return 'مشكلة في الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت ثم إعادة المحاولة.';
    }
    
    if (errorStr.contains('permission') || 
        errorStr.contains('denied') || 
        errorStr.contains('exact_alarm')) {
      return 'تم رفض صلاحية مطلوبة (مثل الإشعارات أو تحديد الموقع أو المنبهات الدقيقة). يرجى تفعيل الصلاحية من إعدادات النظام لتجنب المشاكل.';
    }
    
    if (errorStr.contains('remoteserviceexception') || 
        errorStr.contains('cannotpostforegroundservice')) {
      return 'فشل تشغيل إشعارات الخدمة الخلفية بسبب إعدادات النظام. يرجى منح صلاحيات الإشعارات للتطبيق.';
    }

    if (errorStr.contains('impeller') || errorStr.contains('vulkan') || errorStr.contains('opengl')) {
      return 'حدثت مشكلة أثناء رندر الجرافيكس. يرجى إعادة تشغيل التطبيق.';
    }

    return 'تنبيه: واجه التطبيق خطأ بسيطاً، يرجى المحاولة لاحقاً.\nالخطأ: ${error.toString()}';
  }

  /// Global logger for exceptions
  static void logError(Object error, StackTrace? stackTrace) {
    debugPrint('================ GLOBAL ERROR CAUGHT ================');
    debugPrint('Exception: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    debugPrint('=====================================================');
  }

  /// Builds a beautiful, fallback Arabic UI instead of the Red Screen of Death
  static Widget buildErrorWidget(FlutterErrorDetails details) {
    final exception = details.exception;
    final arabicMsg = getArabicMessage(exception);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F2027),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 84,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حدث خطأ غير متوقع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      arabicMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Try to restart app or return to default route
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'محاولة الاستمرار',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
