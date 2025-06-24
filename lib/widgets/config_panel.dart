import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'auto_save_mixin.dart';
import 'common_widgets.dart';

class ConfigPanel extends ConsumerStatefulWidget {
  const ConfigPanel({super.key});

  @override
  ConsumerState<ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends ConsumerState<ConfigPanel> with AutoSaveMixin {
  late TextEditingController _promptController;
  late TextEditingController _regexController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;

  String _selectedProvider = 'OpenRouter';

  final List<String> _providers = [
    'OpenRouter',
    'OpenAI',
    'Azure OpenAI',
    '自定义',
  ];

  // 默认配置模板，仅在用户首次切换到某个提供商时使用
  final Map<String, Map<String, String>> _providerDefaults = {
    'OpenRouter': {
      'baseUrl': 'https://openrouter.ai/api/v1',
      'model': 'google/gemini-2.0-flash-001',
    },
    'OpenAI': {'baseUrl': 'https://api.openai.com/v1', 'model': 'gpt-4.1-mini'},
    'Azure OpenAI': {
      'baseUrl': 'https://your-resource.openai.azure.com',
      'model': 'gpt-4.1-mini',
    },
    '自定义': {'baseUrl': '', 'model': ''},
  };

  @override
  void initState() {
    super.initState();
    // 使用默认配置初始化控制器
    _initControllers(const TranslationConfig());

    // 延迟加载实际配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(configProvider);
      onConfigChanged(config);
    });
  }

  void _initControllers(TranslationConfig config) {
    _promptController = TextEditingController(text: config.promptTemplate);
    _regexController = TextEditingController(text: config.outputRegex);

    final currentConfig = config.currentLLMConfig;
    _baseUrlController = TextEditingController(text: currentConfig.baseUrl);
    _apiKeyController = TextEditingController(text: currentConfig.apiKey);
    _modelController = TextEditingController(text: currentConfig.model);
    _selectedProvider = config.currentProvider;
  }

  @override
  void onConfigChanged(TranslationConfig config) {
    if (mounted && !isUserEditing) {
      final currentConfig = config.currentLLMConfig;

      setState(() {
        _promptController.text = config.promptTemplate;
        _regexController.text = config.outputRegex;

        _baseUrlController.text = currentConfig.baseUrl;
        _apiKeyController.text = currentConfig.apiKey;
        _modelController.text = currentConfig.model;
        _selectedProvider = config.currentProvider;
      });

      // 模型重新加载现在由ModelNotifier自动处理
    }
  }

  @override
  TranslationConfig createUpdatedConfig(TranslationConfig currentConfig) {
    // 更新当前提供商的配置
    final updatedProviderConfig = LLMProviderConfig(
      baseUrl: _baseUrlController.text,
      apiKey: _apiKeyController.text,
      model: _modelController.text,
    );

    return currentConfig
        .updateProviderConfig(_selectedProvider, updatedProviderConfig)
        .copyWith(
          promptTemplate: _promptController.text,
          outputRegex: _regexController.text,
          currentProvider: _selectedProvider,
        );
  }

  @override
  bool configsAreEqual(TranslationConfig a, TranslationConfig b) {
    final aCurrentConfig = a.currentLLMConfig;
    final bCurrentConfig = b.currentLLMConfig;

    return a.promptTemplate == b.promptTemplate &&
        a.outputRegex == b.outputRegex &&
        a.currentProvider == b.currentProvider &&
        aCurrentConfig.baseUrl == bCurrentConfig.baseUrl &&
        aCurrentConfig.apiKey == bCurrentConfig.apiKey &&
        aCurrentConfig.model == bCurrentConfig.model;
  }

  @override
  void dispose() {
    _promptController.dispose();
    _regexController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onProviderChanged(String? provider) {
    if (provider != null && provider != _selectedProvider) {
      // 先保存当前提供商的配置
      final currentConfig = ref.read(configProvider);
      final updatedCurrentProviderConfig = LLMProviderConfig(
        baseUrl: _baseUrlController.text,
        apiKey: _apiKeyController.text,
        model: _modelController.text,
      );

      final configWithCurrentSaved = currentConfig.updateProviderConfig(
        _selectedProvider,
        updatedCurrentProviderConfig,
      );

      // 获取目标提供商的已保存配置，如果没有则使用默认值
      LLMProviderConfig targetConfig =
          configWithCurrentSaved.llmProviders[provider] ??
          const LLMProviderConfig();

      // 如果目标提供商的配置是空的（首次切换），使用默认配置
      if (targetConfig.baseUrl.isEmpty && targetConfig.model.isEmpty) {
        final defaults = _providerDefaults[provider]!;
        targetConfig = LLMProviderConfig(
          baseUrl: defaults['baseUrl']!,
          apiKey: targetConfig.apiKey, // 保留已设置的API密钥
          model: defaults['model']!,
        );
      }

      setState(() {
        _selectedProvider = provider;
        _baseUrlController.text = targetConfig.baseUrl;
        _apiKeyController.text = targetConfig.apiKey;
        _modelController.text = targetConfig.model;
      });

      // 保存配置
      final finalConfig = configWithCurrentSaved
          .updateProviderConfig(provider, targetConfig)
          .switchProvider(provider);

      ref.read(configProvider.notifier).updateConfig(finalConfig);
    }
  }

  void _onModelSelected(String model) {
    if (_modelController.text != model) {
      _modelController.text = model;

      // 触发自动保存
      scheduleAutoSave();
    }
  }

  Widget _buildModelSelector() {
    final modelState = ref.watch(modelProvider(_selectedProvider));

    return SearchableModelDropdown(
      value: _modelController.text,
      models: modelState.models,
      isLoading: modelState.isLoading,
      error: modelState.error,
      onModelSelected: _onModelSelected,
      onRefresh: () {
        ref.read(modelProvider(_selectedProvider).notifier).refreshModels();
      },
      label: '模型',
      hint: '选择或输入模型名称',
    );
  }

  @override
  Widget build(BuildContext context) {
    // 设置配置监听器
    setupConfigListener();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        PageHeader(title: '应用配置', subtitle: '配置翻译服务的各项参数', icon: Icons.tune),
        const SizedBox(height: AppTheme.spacingXXXLarge),

        // LLM 服务配置卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: 'LLM 服务配置', icon: Icons.psychology),
              const SizedBox(height: AppTheme.spacingXLarge),
              SearchableDropdown<String>(
                label: 'LLM 服务提供商',
                value: _selectedProvider,
                items: _providers,
                onSelected: (value) => _onProviderChanged(value),
                getItemId: (item) => item,
                getItemName: (item) => item,
                hint: '选择服务提供商',
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              buildAutoSaveTextField(
                controller: _baseUrlController,
                label: 'API 基础 URL',
                hint: 'https://openrouter.ai/api/v1',
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: buildAutoSaveTextField(
                      controller: _apiKeyController,
                      label: 'API 密钥',
                      hint: '输入您的 API 密钥',
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingLarge),
                  Expanded(child: _buildModelSelector()),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingXXLarge),

        // 提示词配置卡片
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(title: '提示词配置', icon: Icons.edit_note),
              const SizedBox(height: AppTheme.spacingXLarge),
              buildAutoSaveTextField(
                controller: _promptController,
                label: '提示词模板',
                hint: '支持 {from}, {to}, {text} 变量',
                maxLines: null,
                minLines: 4,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              buildAutoSaveTextField(
                controller: _regexController,
                label: '输出提取正则表达式',
                hint: r'Translation:\s*(.+)',
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              InfoBox.info(
                message: '提示词模板支持变量：{from} 源语言，{to} 目标语言，{text} 待翻译文本',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
