import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/generated/app_localizations.dart';
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
          title: AppLocalizations.of(context).serverControl,
          subtitle: AppLocalizations.of(context).serverControlSubtitle,
          icon: Icons.power_settings_new,
        ),
        const SizedBox(height: AppTheme.spacingXXXLarge),

        // 服务配置卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                title: AppLocalizations.of(context).serverConfiguration,
                icon: Icons.settings,
              ),
              const SizedBox(height: AppTheme.spacingXLarge),
              Row(
                children: [
                  Expanded(
                    child: buildAutoSaveTextField(
                      controller: _portController,
                      label: AppLocalizations.of(context).httpServerPort,
                      hint: '8080',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingLarge),
                  Expanded(
                    child: buildAutoSaveTextField(
                      controller: _concurrencyController,
                      label: AppLocalizations.of(context).concurrencyCount,
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
              CardHeader(
                title: AppLocalizations.of(context).serverStatus,
                icon: Icons.dns,
              ),
              const SizedBox(height: AppTheme.spacingXLarge),

              // 状态指示器
              StatusIndicator(
                isActive: serverState.isRunning,
                activeText: AppLocalizations.of(context).serverRunning,
                inactiveText: AppLocalizations.of(context).serverStopped,
                subtitle: serverState.isRunning
                    ? AppLocalizations.of(context).port(serverState.port!)
                    : null,
              ),

              // 错误信息
              if (serverState.error != null) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                InfoBox.error(
                  message: AppLocalizations.of(
                    context,
                  ).error(serverState.error!),
                ),
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
                      label: Text(AppLocalizations.of(context).startServer),
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
                      label: Text(AppLocalizations.of(context).stopServer),
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
                CardHeader(
                  title: AppLocalizations.of(context).apiEndpoints,
                  icon: Icons.api,
                ),
                const SizedBox(height: AppTheme.spacingXLarge),

                CodeBlock(
                  title: AppLocalizations.of(context).translateEndpoint,
                  description: AppLocalizations.of(context).translateEndpoint,
                  code:
                      'curl "http://localhost:${serverState.port}/translate?from=en&to=zh&text=Hello"',
                  icon: Icons.translate,
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                CodeBlock(
                  title: AppLocalizations.of(context).healthCheckEndpoint,
                  description: AppLocalizations.of(
                    context,
                  ).healthCheckEndpoint,
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
