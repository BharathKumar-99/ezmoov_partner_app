import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleViewModel extends ChangeNotifier {
  static const String _localeKey = 'app_language_code';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleViewModel() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey) ?? 'en';
      if (code == 'hi' || code == 'te' || code == 'en') {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    if (languageCode == 'en' || languageCode == 'hi' || languageCode == 'te') {
      _locale = Locale(languageCode);
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, languageCode);
      } catch (e) {
        debugPrint('Error saving locale: $e');
      }
    }
  }

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'en':
      default:
        return 'English';
    }
  }
}
