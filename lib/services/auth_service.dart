import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'cloud_sync_service.dart';

/// خدمة المصادقة وربط الحسابات السحابية لحماية بيانات المستخدم عبر الأجهزة
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '255874426015-kfmm8bikbn9mp9060c31f26lsklj268b.apps.googleusercontent.com',
  );

  /// المستخدم الحالي
  static User? get currentUser => _auth.currentUser;

  /// فحص هل الحساب الحالي مرتبط بـ Google أم مجهول
  static bool get isLinkedWithGoogle {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  /// فحص هل الحساب الحالي مرتبط بـ Apple أم مجهول
  static bool get isLinkedWithApple {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return user.providerData.any((info) => info.providerId == 'apple.com');
  }

  /// ربط الحساب الحالي بـ Apple لحفظ البيانات واسترجاعها على أجهزة أبل
  static Future<User?> linkWithApple() async {
    try {
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      User? user = _auth.currentUser;

      if (user != null && user.isAnonymous) {
        final userCredential = await user.linkWithProvider(appleProvider);
        user = userCredential.user;
        debugPrint('AuthService: Anonymous user linked successfully with Apple UID: ${user?.uid}');
      } else {
        final userCredential = await _auth.signInWithProvider(appleProvider);
        user = userCredential.user;
        debugPrint('AuthService: Signed in with Apple UID: ${user?.uid}');
      }

      await CloudSyncService.restoreUserDataFromCloud();
      await CloudSyncService.syncUserDataToCloud();

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        final appleProvider = OAuthProvider('apple.com');
        final userCredential = await _auth.signInWithProvider(appleProvider);
        await CloudSyncService.restoreUserDataFromCloud();
        await CloudSyncService.syncUserDataToCloud();
        return userCredential.user;
      }
      debugPrint('AuthService Apple Link Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService Apple Link Error: $e');
      rethrow;
    }
  }

  /// ربط الحساب الحالي بـ Google لحفظ البيانات واسترجاعها على أي هاتف جديد
  static Future<User?> linkWithGoogle() async {
    AuthCredential? credential;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // المستخدم ألغى الاختيار

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? user = _auth.currentUser;

      if (user != null && user.isAnonymous) {
        // دمج الحساب المجهول الحالي مع حساب Google دون فقدان أي بيانات
        final userCredential = await user.linkWithCredential(credential);
        user = userCredential.user;
        debugPrint('AuthService: Anonymous user linked successfully with Google UID: ${user?.uid}');
      } else {
        // تسجيل دخول مباشر بحساب Google واسترجاع بياناته
        final userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;
        debugPrint('AuthService: Signed in with Google UID: ${user?.uid}');
      }

      // استرجاع المزامنة السحابية ثم رفع البيانات المحدثة
      await CloudSyncService.restoreUserDataFromCloud();
      await CloudSyncService.syncUserDataToCloud();

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' && credential != null) {
        // الحساب مستخدم سابقاً على جهاز آخر - تسجيل الدخول به مباشرة واسترجاع بياناته كاملة
        final userCredential = await _auth.signInWithCredential(credential);
        await CloudSyncService.restoreUserDataFromCloud();
        await CloudSyncService.syncUserDataToCloud();
        return userCredential.user;
      }
      debugPrint('AuthService Google Link Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('AuthService Google Link Platform Error: ${e.code} - ${e.message}');
      if (e.code == 'sign_in_failed' || e.message?.contains('10') == true || e.toString().contains('10')) {
        throw Exception('رمز الخطأ (10): إعدادات بصمة SHA-1 غير مكتملة في Firebase Console.');
      }
      throw Exception('خطأ في الاتصال بـ Google: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('AuthService Google Link Error: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج والعودة لحساب مجهول آمن
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('AuthService SignOut Error: $e');
    }
  }
}
