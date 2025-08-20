import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;
  String? _userPhone;
  String? _userId;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userId => _userId;
  bool get isInitialized => _isInitialized;

  // کلیدهای SharedPreferences
  static const String _keyIsLoggedIn = 'user_is_logged_in';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserId = 'user_id';

  UserProvider() {
    _loadUserData();
  }

  /// بارگذاری اطلاعات کاربر از SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userName = prefs.getString(_keyUserName);
      _userPhone = prefs.getString(_keyUserPhone);
      _userId = prefs.getString(_keyUserId);

      _isInitialized = true;
      notifyListeners();

      debugPrint(
          'UserProvider loaded: isLoggedIn=$_isLoggedIn, userName=$_userName, phone=$_userPhone, userId=$_userId');
    } catch (e) {
      debugPrint('خطا در بارگذاری اطلاعات کاربر: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// ذخیره اطلاعات کاربر در SharedPreferences
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_keyIsLoggedIn, _isLoggedIn);
      if (_userName != null) {
        await prefs.setString(_keyUserName, _userName!);
      } else {
        await prefs.remove(_keyUserName);
      }
      if (_userPhone != null) {
        await prefs.setString(_keyUserPhone, _userPhone!);
      } else {
        await prefs.remove(_keyUserPhone);
      }
      if (_userId != null) {
        await prefs.setString(_keyUserId, _userId!);
      } else {
        await prefs.remove(_keyUserId);
      }

      debugPrint(
          'UserProvider saved: isLoggedIn=$_isLoggedIn, userName=$_userName, phone=$_userPhone, userId=$_userId');
    } catch (e) {
      debugPrint('خطا در ذخیره اطلاعات کاربر: $e');
    }
  }

  /// ورود کاربر
  Future<void> login({String? name, String? phone}) async {
    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;

    await _saveUserData();
    notifyListeners();
  }

  /// به‌روزرسانی اطلاعات کاربر
  Future<void> updateUserInfo({String? name, String? phone}) async {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;

    await _saveUserData();
    notifyListeners();
  }

  /// تنظیم userId برای کش کردن
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _saveUserData();
    notifyListeners();
  }

  /// خروج کاربر
  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userPhone = null;
    _userId = null;

    await _saveUserData();
    notifyListeners();
  }

  /// پاک کردن کامل اطلاعات (برای debugging)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserPhone);
      await prefs.remove(_keyUserId);

      _isLoggedIn = false;
      _userName = null;
      _userPhone = null;
      _userId = null;

      notifyListeners();
      debugPrint('تمام اطلاعات کاربر پاک شد');
    } catch (e) {
      debugPrint('خطا در پاک کردن اطلاعات: $e');
    }
  }
}
