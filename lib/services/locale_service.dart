import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';

  // 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh'), // 中文
    Locale('en'), // 英文
  ];

  // 语言显示名称映射
  static const Map<String, String> localeNames = {'zh': '中文', 'en': 'English'};

  /// 获取保存的语言设置
  static Future<Locale?> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null) {
        return Locale(localeCode);
      }
    } catch (e) {
      // 如果获取失败，返回null使用系统默认语言
    }
    return null;
  }

  /// 保存语言设置
  static Future<bool> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      return false;
    }
  }

  /// 清除保存的语言设置
  static Future<bool> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_localeKey);
    } catch (e) {
      return false;
    }
  }

  /// 获取系统语言，如果不支持则返回默认语言（中文）
  static Locale getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;

    // 检查系统语言是否在支持列表中
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 如果系统语言不支持，返回中文作为默认语言
    return const Locale('zh');
  }

  /// 获取语言显示名称
  static String getLocaleName(Locale locale) {
    return localeNames[locale.languageCode] ?? locale.languageCode;
  }

  /// 检查是否支持指定语言
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}
