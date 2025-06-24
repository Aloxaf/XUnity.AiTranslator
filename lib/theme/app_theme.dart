import 'package:flutter/material.dart';

class AppTheme {
  // 主要颜色
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color contentBackgroundColor = Color(0xFF0F0F0F);
  static const Color onSurfaceColor = Color(0xFFE5E5E5);
  static const Color onBackgroundColor = Color(0xFFE5E5E5);

  // 状态颜色
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color neutralColor = Color(0xFF6B7280);

  // 边框颜色
  static Color get borderColor => Colors.grey.shade800.withValues(alpha: 0.5);
  static Color get borderColorLight =>
      Colors.grey.shade800.withValues(alpha: 0.3);
  static Color get dividerColor => Colors.grey.shade800.withValues(alpha: 0.3);

  // 文本颜色
  static Color get textPrimary => Colors.white;
  static Color get textSecondary => Colors.white.withValues(alpha: 0.6);
  static Color get textTertiary => Colors.white.withValues(alpha: 0.4);
  static Color get textDisabled => Colors.grey.shade500;

  // 圆角半径
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;

  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingXXXLarge = 32.0;

  // 图标尺寸
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  // 装饰器工厂方法
  static BoxDecoration cardDecoration({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(radiusXLarge),
      border: Border.all(color: borderColor ?? AppTheme.borderColor),
    );
  }

  static BoxDecoration contentDecoration({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? contentBackgroundColor,
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(color: borderColor ?? borderColorLight),
    );
  }

  static BoxDecoration chipDecoration({
    required Color color,
    double alpha = 0.1,
    double borderAlpha = 0.3,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(radiusSmall),
      border: Border.all(color: color.withValues(alpha: borderAlpha)),
    );
  }

  static BoxDecoration statusDecoration({
    required Color color,
    double alpha = 0.1,
    double borderAlpha = 0.3,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(color: color.withValues(alpha: borderAlpha)),
    );
  }

  static BoxDecoration iconContainerDecoration({
    Color? color,
    double alpha = 0.1,
  }) {
    return BoxDecoration(
      color: (color ?? primaryColor).withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(radiusMedium),
    );
  }

  static BoxDecoration badgeDecoration({
    Color? color,
    double alpha = 0.1,
    double borderAlpha = 0.3,
  }) {
    return BoxDecoration(
      color: (color ?? primaryColor).withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(radiusXXLarge),
      border: Border.all(
        color: (color ?? primaryColor).withValues(alpha: borderAlpha),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: Colors.grey.shade800,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        hintStyle: const TextStyle(color: Color(0xFF666666)),
      ),
    );
  }
}
