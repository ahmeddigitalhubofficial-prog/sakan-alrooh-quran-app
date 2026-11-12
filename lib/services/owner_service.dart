import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// خدمة وضع المالك والمطور الحصري (Owner & Developer Privileges)
class OwnerService extends ChangeNotifier {
  static final OwnerService _instance = OwnerService._internal();
  factory OwnerService() => _instance;
  OwnerService._internal() {
    _init();
  }

  static const String _ownerPrefKey = 'is_owner_dev_mode_active';
  static const String _secretMasterPin = '1992'; // الرمز السري الحصري للمالك
  static const String ownerEmail = 'ahmed.digitalhub.official@gmail.com'; // بريد المالك الرسمي

  bool _isOwner = false;
  bool get isOwner => _isOwner;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isOwner = prefs.getBool(_ownerPrefKey) ?? false;
    
    // التحقق التلقائي إذا كان الحساب الحالي للمالك
    checkAutoOwnerAuth();

    try {
      FirebaseAuth.instance.authStateChanges().listen((_) {
        checkAutoOwnerAuth();
      });
    } catch (_) {}
  }

  /// التحقق التلقائي عند تسجيل الدخول بحساب Google
  void checkAutoOwnerAuth() {
    final user = AuthService.currentUser;
    if (user != null && !user.isAnonymous && user.email != null) {
      if (user.email!.toLowerCase().trim() == ownerEmail.toLowerCase()) {
        setOwnerMode(true);
      }
    }
  }

  /// تفعيل وضع المالك بالرمز السري الحصري
  Future<bool> verifyAndActivate(String pin) async {
    if (pin.trim() == _secretMasterPin) {
      await setOwnerMode(true);
      return true;
    }
    return false;
  }

  /// تبديل وضع المالك
  Future<void> setOwnerMode(bool value) async {
    _isOwner = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ownerPrefKey, value);
    notifyListeners();
  }
}
