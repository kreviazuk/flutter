import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌐 语言管理服务
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  // 单例模式
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('zh'); // 默认中文

  Locale get currentLocale => _currentLocale;

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh'), // 中文
    Locale('en'), // 英文
  ];

  /// 获取语言显示名称
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  /// 初始化语言设置
  Future<void> initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      print('初始化语言设置失败: $e');
    }
  }

  /// 更改语言
  Future<void> changeLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);

      _currentLocale = locale;
      notifyListeners();
    } catch (e) {
      print('保存语言设置失败: $e');
      throw Exception('保存语言设置失败');
    }
  }

  /// 切换语言（中英文切换）
  Future<void> toggleLanguage() async {
    final newLocale = _currentLocale.languageCode == 'zh' ? const Locale('en') : const Locale('zh');
    await changeLanguage(newLocale);
  }
}
