import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;
  String? _userPhone;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userPhone => _userPhone;

  UserProvider() {
    // وضعیت اولیه را از Supabase بگیر
    _isLoggedIn = Supabase.instance.client.auth.currentUser != null;
  }

  void login({String? name, String? phone}) {
    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;
    notifyListeners();
  }

  void updateUserInfo({String? name, String? phone}) {
    if (name != null) _userName = name;
    if (phone != null) _userPhone = phone;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    _userPhone = null;
    notifyListeners();
  }
}
