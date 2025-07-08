import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  final Map<String, String> _languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
    'hi': 'हिन्दी',
  };

  Map<String, String> get supportedLanguages => _languages;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final savedLanguage = await DatabaseHelper.instance.getSetting('language');
    if (savedLanguage != null && _languages.containsKey(savedLanguage)) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_languages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      await DatabaseHelper.instance.setSetting('language', languageCode);
      notifyListeners();
    }
  }

  String getLanguageName(String code) {
    return _languages[code] ?? 'Unknown';
  }
}
