import 'package:flutter/foundation.dart';
import 'package:huawei_account/huawei_account.dart';

class HuaweiUserData {
  final String openId;
  final String? unionId;
  final String? displayName;
  final String? email;
  final String? avatarUri;

  HuaweiUserData({
    required this.openId,
    this.unionId,
    this.displayName,
    this.email,
    this.avatarUri,
  });
}

class HuaweiAuthService {
  static final HuaweiAuthService _instance = HuaweiAuthService._internal();
  factory HuaweiAuthService() => _instance;
  HuaweiAuthService._internal();

  AccountAuthService? _authService;

  void _initAuthService() {
    if (_authService != null) return;
    try {
      final AccountAuthParamsHelper helper = AccountAuthParamsHelper();
      helper
        ..setId()
        ..setProfile()
        ..setEmail();
      final AccountAuthParams params = helper.createParams();
      _authService = AccountAuthManager.getService(params);
    } catch (e) {
      debugPrint('HuaweiAuthService init error: $e');
    }
  }

  /// Attempts to sign in with Huawei ID safely
  Future<HuaweiUserData?> signIn() async {
    try {
      _initAuthService();
      if (_authService == null) return null;

      final AuthAccount authAccount = await _authService!.signIn();
      debugPrint('Huawei Sign-In Successful for OpenID: ${authAccount.openId}');

      return HuaweiUserData(
        openId: authAccount.openId ?? '',
        unionId: authAccount.unionId,
        displayName: authAccount.displayName,
        email: authAccount.email,
        avatarUri: authAccount.avatarUri,
      );
    } catch (e) {
      debugPrint('Huawei Sign-In Error: $e');
      return null;
    }
  }

  /// Signs out from Huawei ID
  Future<bool> signOut() async {
    try {
      _initAuthService();
      if (_authService == null) return true;
      await _authService!.signOut();
      return true;
    } catch (e) {
      debugPrint('Huawei Sign-Out Error: $e');
      return false;
    }
  }

  /// Silently checks if already signed in
  Future<HuaweiUserData?> silentSignIn() async {
    try {
      _initAuthService();
      if (_authService == null) return null;
      final AuthAccount authAccount = await _authService!.silentSignIn();
      if (authAccount.openId != null && authAccount.openId!.isNotEmpty) {
        return HuaweiUserData(
          openId: authAccount.openId!,
          unionId: authAccount.unionId,
          displayName: authAccount.displayName,
          email: authAccount.email,
          avatarUri: authAccount.avatarUri,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Huawei Silent Sign-In Error: $e');
      return null;
    }
  }
}
