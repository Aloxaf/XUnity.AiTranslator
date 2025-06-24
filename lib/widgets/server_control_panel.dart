import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'auto_save_mixin.dart';
import 'common_widgets.dart';

class ServerControlPanel extends ConsumerStatefulWidget {
  const ServerControlPanel({super.key});

  @override
  ConsumerState<ServerControlPanel> createState() => _ServerControlPanelState();
}

class _ServerControlPanelState extends ConsumerState<ServerControlPanel>
    with AutoSaveMixin {
  late TextEditingController _portController;
  late TextEditingController _concurrencyController;

  @override
  void initState() {
    super.initState();
    // 使用默认配置初始化控制器
    _initControllers(TranslationConfig.defaultConfig());

    // 延迟加载实际配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(configProvider);
      onConfigChanged(config);
    });
  }

  void _initControllers(TranslationConfig config) {
    _portController = TextEditingController(text: config.serverPort.toString());
    _concurrencyController = TextEditingController(
      text: config.concurrency.toString(),
    );
  }

  @override
  void onConfigChanged(TranslationConfig config) {
    if (mounted && !isUserEditing) {
      setState(() {
        _portController.text = config.serverPort.toString();
        _concurrencyController.text = config.concurrency.toString();
      });
    }
  }

  @override
  TranslationConfig createUpdatedConfig(TranslationConfig currentConfig) {
    return currentConfig.copyWith(
      serverPort: int.tryParse(_portController.text) ?? 8080,
      concurrency: int.tryParse(_concurrencyController.text) ?? 3,
    );
  }

  @override
  bool configsAreEqual(TranslationConfig a, TranslationConfig b) {
    return a.serverPort == b.serverPort && a.concurrency == b.concurrency;
  }

  @override
  void dispose() {
    _portController.dispose();
    _concurrencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverStateProvider);
    final config = ref.watch(configProvider);

    // 设置配置监听器
    setupConfigListener();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        PageHeader(
          title: '服务控制',
          subtitle: '启动和管理 HTTP 翻译服务',
          icon: Icons.power_settings_new,
        ),
        const SizedBox(height: AppTheme.spacingXXXLarge),

        // 服务配置卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: '服务配置', icon: Icons.settings),
              const SizedBox(height: AppTheme.spacingXLarge),
              Row(
                children: [
                  Expanded(
                    child: buildAutoSaveTextField(
                      controller: _portController,
                      label: 'HTTP 服务端口',
                      hint: '8080',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingLarge),
                  Expanded(
                    child: buildAutoSaveTextField(
                      controller: _concurrencyController,
                      label: '并发数量',
                      hint: '3',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingXXLarge),

        // 服务器状态卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: '服务器状态', icon: Icons.dns),
              const SizedBox(height: AppTheme.spacingXLarge),

              // 状态指示器
              StatusIndicator(
                isActive: serverState.isRunning,
                activeText: '服务器运行中',
                inactiveText: '服务器已停止',
                subtitle: serverState.isRunning
                    ? '端口: ${serverState.port}'
                    : null,
              ),

              // 错误信息
              if (serverState.error != null) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                InfoBox.error(message: '错误: ${serverState.error}'),
              ],

              const SizedBox(height: AppTheme.spacingXXLarge),

              // 控制按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: serverState.isRunning
                          ? null
                          : () => ref
                                .read(serverStateProvider.notifier)
                                .startServer(config.serverPort),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('启动服务器'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade800,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: serverState.isRunning
                          ? () => ref
                                .read(serverStateProvider.notifier)
                                .stopServer()
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('停止服务器'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade800,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // API 端点信息
        if (serverState.isRunning) ...[
          const SizedBox(height: AppTheme.spacingXXLarge),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(title: 'API 端点信息', icon: Icons.api),
                const SizedBox(height: AppTheme.spacingXLarge),

                CodeBlock(
                  title: '翻译端点',
                  description: '用于翻译文本的主要 API 端点',
                  code:
                      'curl "http://localhost:${serverState.port}/translate?from=en&to=zh&text=Hello"',
                  icon: Icons.translate,
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                CodeBlock(
                  title: '健康检查',
                  description: '检查服务器运行状态',
                  code: 'curl "http://localhost:${serverState.port}/health"',
                  icon: Icons.health_and_safety,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
