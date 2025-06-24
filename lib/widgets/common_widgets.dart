import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/llm_service.dart';

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

/// 基础下拉组件 - 抽象公共逻辑
abstract class BaseDropdown<T> extends StatefulWidget {
  final String? value;
  final List<T> items;
  final void Function(String) onSelected;
  final String label;
  final String hint;
  final String Function(T) getItemId;
  final String Function(T) getItemName;

  const BaseDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.getItemId,
    required this.getItemName,
    this.label = '选择项',
    this.hint = '请选择',
  });
}

abstract class BaseDropdownState<T, W extends BaseDropdown<T>>
    extends State<W> {
  late TextEditingController controller;
  late FocusNode focusNode;
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  bool showDropdown = false;

  // 抽象方法 - 子类实现
  List<T> get displayItems;
  bool get isInputReadOnly => false;
  String get displayText;
  Widget buildDropdownContent();
  void onTextChanged(String text) {}
  List<Widget> buildSuffixIcons();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: displayText);
    focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showDropdown = true;
        showOverlay();
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !focusNode.hasFocus) {
            hideOverlay();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      controller.text = displayText;
    }
    onWidgetUpdated(oldWidget);
  }

  void onWidgetUpdated(W oldWidget) {}

  @override
  void dispose() {
    hideOverlay();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void showOverlay() {
    if (overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
    showDropdown = false;
  }

  Widget buildDefaultItemList() {
    if (displayItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Text(
          '没有可用的选项',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final item = displayItems[index];
        final itemId = widget.getItemId(item);
        final isSelected = itemId == widget.value;

        return InkWell(
          onTap: () {
            controller.text = widget.getItemName(item);
            widget.onSelected(itemId);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                focusNode.unfocus();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : null,
            child: Text(
              widget.getItemName(item),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        CompositedTransformTarget(
          link: layerLink,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: isInputReadOnly,
            onChanged: onTextChanged,
            onFieldSubmitted: (value) {
              if (value.isNotEmpty && !isInputReadOnly) {
                widget.onSelected(value);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppTheme.textDisabled),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...buildSuffixIcons(),
                  Icon(
                    showDropdown
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                ],
              ),
            ),
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// 通用的带搜索功能的下拉选择组件 - 基于BaseDropdown重构
class SearchableDropdown<T> extends BaseDropdown<T> {
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final String? Function(T)? getItemDescription;
  final bool Function(T, String)? customFilter;

  const SearchableDropdown({
    super.key,
    required super.value,
    required super.items,
    required super.onSelected,
    required super.getItemId,
    required super.getItemName,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    super.label = '选择项',
    super.hint = '选择或输入',
    this.getItemDescription,
    this.customFilter,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T>
    extends BaseDropdownState<T, SearchableDropdown<T>> {
  List<T> _filteredItems = [];

  @override
  List<T> get displayItems => _filteredItems;

  @override
  String get displayText => widget.value ?? '';

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void onWidgetUpdated(SearchableDropdown<T> oldWidget) {
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _filterItems(controller.text);
        }
      });
    }
  }

  @override
  void onTextChanged(String text) {
    _filterItems(text);
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.customFilter != null) {
            return widget.customFilter!(item, query);
          }
          final id = widget.getItemId(item).toLowerCase();
          final name = widget.getItemName(item).toLowerCase();
          final queryLower = query.toLowerCase();
          return id.contains(queryLower) || name.contains(queryLower);
        }).toList();
      }
    });

    if (showDropdown && overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && overlayEntry != null) {
          overlayEntry!.markNeedsBuild();
        }
      });
    }
  }

  @override
  Widget buildDropdownContent() {
    if (widget.isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            const Text('加载中...', style: TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    if (widget.error != null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Text(
                    widget.error!,
                    style: TextStyle(fontSize: 14, color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: AppTheme.spacingMedium),
              TextButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重试'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Text(
          controller.text.isEmpty ? '没有可用的选项' : '未找到匹配的选项',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final itemId = widget.getItemId(item);
        final isSelected = itemId == widget.value;

        return InkWell(
          onTap: () {
            controller.text = itemId;
            widget.onSelected(itemId);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                focusNode.unfocus();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.getItemName(item),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                ),
                if (widget.getItemDescription != null) ...[
                  () {
                    final description = widget.getItemDescription!(item);
                    if (description != null && description.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  List<Widget> buildSuffixIcons() {
    return [
      if (widget.isLoading)
        Padding(
          padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        )
      else if (widget.onRefresh != null)
        IconButton(
          onPressed: widget.onRefresh,
          icon: Icon(Icons.refresh, size: 18, color: AppTheme.textSecondary),
          tooltip: '刷新列表',
        ),
    ];
  }
}

/// 简单的下拉选择组件 - 基于BaseDropdown重构
class SimpleDropdown<T> extends BaseDropdown<T> {
  const SimpleDropdown({
    super.key,
    required super.value,
    required super.items,
    required super.onSelected,
    required super.getItemId,
    required super.getItemName,
    super.label = '选择项',
    super.hint = '请选择',
  });

  @override
  State<SimpleDropdown<T>> createState() => _SimpleDropdownState<T>();
}

class _SimpleDropdownState<T> extends BaseDropdownState<T, SimpleDropdown<T>> {
  @override
  List<T> get displayItems => widget.items;

  @override
  bool get isInputReadOnly => true;

  @override
  String get displayText {
    if (widget.value != null) {
      final item = widget.items
          .where((item) => widget.getItemId(item) == widget.value)
          .firstOrNull;
      if (item != null) {
        return widget.getItemName(item);
      }
    }
    return '';
  }

  @override
  Widget buildDropdownContent() => buildDefaultItemList();

  @override
  List<Widget> buildSuffixIcons() => [];
}

class SearchableModelDropdown extends StatelessWidget {
  final String? value;
  final List<ModelInfo> models;
  final bool isLoading;
  final String? error;
  final void Function(String) onModelSelected;
  final VoidCallback? onRefresh;
  final String label;
  final String hint;

  const SearchableModelDropdown({
    super.key,
    required this.value,
    required this.models,
    required this.onModelSelected,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.label = '模型',
    this.hint = '选择或输入模型名称',
  });

  @override
  Widget build(BuildContext context) {
    return SearchableDropdown<ModelInfo>(
      value: value,
      items: models,
      isLoading: isLoading,
      error: error,
      onSelected: onModelSelected,
      onRefresh: onRefresh,
      label: label,
      hint: hint,
      getItemId: (model) => model.id,
      getItemName: (model) => model.name,
      getItemDescription: (model) => model.description,
    );
  }
}
