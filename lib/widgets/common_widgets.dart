import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// 通用卡片容器
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingXXLarge),
      decoration: AppTheme.cardDecoration(
        color: color,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}

/// 带图标的卡片标题
class CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? actions;

  const CardHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: AppTheme.iconSizeMedium,
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

/// 页面标题组件
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: AppTheme.iconContainerDecoration(
                color: iconColor ?? AppTheme.primaryColor,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: AppTheme.iconSizeMedium,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// 状态指示器
class StatusIndicator extends StatelessWidget {
  final bool isActive;
  final String activeText;
  final String inactiveText;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? subtitle;

  const StatusIndicator({
    super.key,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
    this.activeColor,
    this.inactiveColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppTheme.successColor)
        : (inactiveColor ?? AppTheme.neutralColor);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.statusDecoration(color: color),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? activeText : inactiveText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingXSmall,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '在线',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 信息提示框
class InfoBox extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;

  const InfoBox({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.borderColor,
  });

  factory InfoBox.info({required String message, IconData? icon}) {
    return InfoBox(
      message: message,
      icon: icon ?? Icons.info_outline,
      color: AppTheme.infoColor,
    );
  }

  factory InfoBox.error({required String message, IconData? icon}) {
    return InfoBox(
      message: message,
      icon: icon ?? Icons.error_outline,
      color: AppTheme.errorColor,
    );
  }

  factory InfoBox.success({required String message, IconData? icon}) {
    return InfoBox(
      message: message,
      icon: icon ?? Icons.check_circle_outline,
      color: AppTheme.successColor,
    );
  }

  factory InfoBox.warning({required String message, IconData? icon}) {
    return InfoBox(
      message: message,
      icon: icon ?? Icons.warning_amber_outlined,
      color: AppTheme.warningColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: borderColor ?? color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppTheme.iconSizeSmall),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// 标签芯片
class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
  });

  factory AppChip.primary({
    required String label,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return AppChip(
      label: label,
      color: AppTheme.primaryColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  factory AppChip.success({
    required String label,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return AppChip(
      label: label,
      color: AppTheme.successColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  factory AppChip.error({
    required String label,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return AppChip(
      label: label,
      color: AppTheme.errorColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  factory AppChip.neutral({
    required String label,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return AppChip(
      label: label,
      color: AppTheme.neutralColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.neutralColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: AppTheme.chipDecoration(color: chipColor),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: fontSize ?? 12,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
      ),
    );
  }
}

/// 徽章组件
class AppBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const AppBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: AppTheme.badgeDecoration(color: badgeColor),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 可复制的代码块
class CodeBlock extends StatelessWidget {
  final String code;
  final String? title;
  final String? description;
  final IconData? icon;

  const CodeBlock({
    super.key,
    required this.code,
    this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: AppTheme.contentDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: AppTheme.iconContainerDecoration(
                      color: AppTheme.infoColor,
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.infoColor,
                      size: AppTheme.iconSizeSmall,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                ],
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppTheme.spacingMedium),
          ],
          if (description != null) ...[
            Text(
              description!,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('已复制到剪贴板'),
                          backgroundColor: AppTheme.successColor,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.copy,
                    size: AppTheme.iconSizeSmall,
                    color: AppTheme.textSecondary,
                  ),
                  tooltip: '复制',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 空状态组件
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppTheme.textDisabled),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              subtitle!,
              style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppTheme.spacingXXLarge),
            action!,
          ],
        ],
      ),
    );
  }
}
