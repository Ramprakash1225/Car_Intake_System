import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  bool get isTamil => _currentLocale.languageCode == 'ta';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ta')
        : const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLocale.languageCode);
    notifyListeners();
  }

  String translate(String english, String tamil) {
    return _currentLocale.languageCode == 'ta' ? tamil : english;
  }
}

