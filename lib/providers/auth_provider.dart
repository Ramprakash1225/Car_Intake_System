import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _mobileNumber = '';

  bool get isAuthenticated => _isAuthenticated;
  String get mobileNumber => _mobileNumber;

  // Get user name based on mobile number
  String? getUserName() {
    if (_mobileNumber == '9999900000') {
      return 'Mr. PalaniKumar';
    }
    return null;
  }

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _mobileNumber = prefs.getString('mobileNumber') ?? '';
    notifyListeners();
  }

  Future<bool> login(String mobileNumber) async {
    final cleaned = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Only allow specific mobile number: 9999900000
    if (cleaned == '9999900000') {
      _isAuthenticated = true;
      _mobileNumber = cleaned;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('mobileNumber', cleaned);

      // Initialize user data storage if not exists
      final userDataKey = 'user_data_$cleaned';
      if (!prefs.containsKey(userDataKey)) {
        await prefs.setString(userDataKey, json.encode({}));
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _mobileNumber = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('mobileNumber');
    notifyListeners();
  }

  // Store data under mobile number
  Future<void> saveUserData(String key, dynamic value) async {
    if (_mobileNumber.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userDataKey = 'user_data_$_mobileNumber';
    final existingDataStr = prefs.getString(userDataKey) ?? '{}';
    final existingData = json.decode(existingDataStr) as Map<String, dynamic>;
    existingData[key] = value;
    await prefs.setString(userDataKey, json.encode(existingData));
  }

  // Get data stored under mobile number
  Future<dynamic> getUserData(String key) async {
    if (_mobileNumber.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final userDataKey = 'user_data_$_mobileNumber';
    final userDataStr = prefs.getString(userDataKey) ?? '{}';
    final userData = json.decode(userDataStr) as Map<String, dynamic>;
    return userData[key];
  }

  // Get all user data
  Future<Map<String, dynamic>> getAllUserData() async {
    if (_mobileNumber.isEmpty) return {};

    final prefs = await SharedPreferences.getInstance();
    final userDataKey = 'user_data_$_mobileNumber';
    final userDataStr = prefs.getString(userDataKey) ?? '{}';
    return json.decode(userDataStr) as Map<String, dynamic>;
  }

  // Clear all application data (except language preference)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get language preference to preserve it
    final language = prefs.getString('language') ?? 'en';

    // Clear all preferences
    await prefs.clear();

    // Restore language preference
    await prefs.setString('language', language);

    // Reset auth state
    _isAuthenticated = false;
    _mobileNumber = '';
    notifyListeners();
  }
}
