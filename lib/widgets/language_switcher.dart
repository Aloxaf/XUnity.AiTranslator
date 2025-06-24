import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';

class LanguageSwitcher extends ConsumerStatefulWidget {
  final String? label;
  final bool showLabel;

  const LanguageSwitcher({super.key, this.label, this.showLabel = true});

  @override
  ConsumerState<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends ConsumerState<LanguageSwitcher> {
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  bool showDropdown = false;

  @override
  void dispose() {
    hideOverlay();
    super.dispose();
  }

  void toggleDropdown() {
    if (showDropdown) {
      hideOverlay();
    } else {
      showOverlay();
    }
  }

  void showOverlay() {
    if (overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: hideOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: 180, // 减小宽度，保持紧凑
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, -100), // 向上弹出
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 160),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      border: Border.all(color: Colors.grey.shade700),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: buildDropdownContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() {
      showDropdown = true;
    });
    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
    if (mounted) {
      setState(() {
        showDropdown = false;
      });
    }
  }

  Widget buildDropdownContent() {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguageCode = currentLocale?.languageCode ?? 'zh';

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXSmall),
      itemCount: LocaleService.supportedLocales.length,
      itemBuilder: (context, index) {
        final locale = LocaleService.supportedLocales[index];
        final isSelected = locale.languageCode == currentLanguageCode;

        return InkWell(
          onTap: () {
            final localeNotifier = ref.read(localeProvider.notifier);
            localeNotifier.setLocale(locale);
            hideOverlay();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: AppTheme.iconSizeSmall,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    LocaleService.localeNames[locale.languageCode] ??
                        locale.languageCode,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  Icon(
                    Icons.check,
                    size: AppTheme.iconSizeSmall,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final currentLanguageCode = currentLocale?.languageCode ?? 'zh';

    return CompositedTransformTarget(
      link: layerLink,
      child: InkWell(
        onTap: toggleDropdown,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSmall,
            vertical: AppTheme.spacingXSmall,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: AppTheme.iconSizeSmall,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: AppTheme.spacingXSmall),
              Text(
                LocaleService.localeNames[currentLanguageCode] ??
                    currentLanguageCode,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppTheme.spacingXSmall),
              Icon(
                showDropdown
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppTheme.primaryColor,
                size: AppTheme.iconSizeSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
