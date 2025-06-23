import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';

/// 自动保存功能的通用 mixin
mixin AutoSaveMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // 自动保存相关状态
  Timer? saveTimer;
  bool isSaving = false;
  bool isUserEditing = false;

  /// 子类需要实现：创建新的配置对象
  TranslationConfig createUpdatedConfig(TranslationConfig currentConfig);

  /// 子类需要实现：比较配置是否相等
  bool configsAreEqual(TranslationConfig a, TranslationConfig b);

  /// 子类可以覆盖：自定义保存成功消息
  String get saveSuccessMessage => '配置已保存';

  /// 子类可以覆盖：自定义保存失败消息前缀
  String get saveErrorPrefix => '自动保存失败';

  @override
  void dispose() {
    saveTimer?.cancel();
    super.dispose();
  }

  /// 计划自动保存
  void scheduleAutoSave() {
    if (isSaving) return;

    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 200), () {
      if (!isUserEditing) {
        autoSaveConfig();
      }
    });
  }

  /// 自动保存配置
  void autoSaveConfig() async {
    if (isSaving || isUserEditing) return;

    try {
      final currentConfig = ref.read(configProvider);
      final newConfig = createUpdatedConfig(currentConfig);

      // 只有配置真的发生变化时才保存
      if (configsAreEqual(currentConfig, newConfig)) {
        return;
      }

      setState(() {
        isSaving = true;
      });

      await ref.read(configProvider.notifier).updateConfig(newConfig);

      if (mounted) {
        _showSaveSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        _showSaveErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  /// 显示保存成功的提示
  void _showSaveSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_done, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(saveSuccessMessage, style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 显示保存失败的提示
  void _showSaveErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$saveErrorPrefix: $error',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 构建带有自动保存功能的文本字段
  Widget buildAutoSaveTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    int? minLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              isUserEditing = hasFocus;
            });

            if (!hasFocus) {
              // 失去焦点时触发自动保存
              scheduleAutoSave();
            }
          },
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            minLines: minLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 设置配置监听器
  void setupConfigListener() {
    ref.listen<TranslationConfig>(configProvider, (previous, next) {
      if (previous != next && !isSaving) {
        onConfigChanged(next);
      }
    });
  }

  /// 子类需要实现：处理配置变化
  void onConfigChanged(TranslationConfig config);
}
