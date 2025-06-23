import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import 'auto_save_mixin.dart';

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
      'model': 'anthropic/claude-3.5-sonnet',
    },
    'OpenAI': {'baseUrl': 'https://api.openai.com/v1', 'model': 'gpt-4'},
    'Azure OpenAI': {
      'baseUrl': 'https://your-resource.openai.azure.com',
      'model': 'gpt-4',
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
      setState(() {
        _promptController.text = config.promptTemplate;
        _regexController.text = config.outputRegex;

        final currentConfig = config.currentLLMConfig;
        _baseUrlController.text = currentConfig.baseUrl;
        _apiKeyController.text = currentConfig.apiKey;
        _modelController.text = currentConfig.model;
        _selectedProvider = config.currentProvider;
      });
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

  @override
  Widget build(BuildContext context) {
    // 设置配置监听器
    setupConfigListener();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '应用配置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '配置翻译服务的各项参数',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),

        // LLM 服务配置卡片
        _buildConfigCard(
          title: 'LLM 服务配置',
          icon: Icons.psychology,
          children: [
            _buildDropdownField(
              label: 'LLM 服务提供商',
              value: _selectedProvider,
              items: _providers,
              onChanged: _onProviderChanged,
            ),
            const SizedBox(height: 16),
            buildAutoSaveTextField(
              controller: _baseUrlController,
              label: 'API 基础 URL',
              hint: 'https://openrouter.ai/api/v1',
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 16),
                Expanded(
                  child: buildAutoSaveTextField(
                    controller: _modelController,
                    label: '模型',
                    hint: 'gpt-4',
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 提示词配置卡片
        _buildConfigCard(
          title: '提示词配置',
          icon: Icons.edit_note,
          children: [
            buildAutoSaveTextField(
              controller: _promptController,
              label: '提示词模板',
              hint: '支持 {from}, {to}, {text} 变量',
              maxLines: null,
              minLines: 4,
            ),
            const SizedBox(height: 16),
            buildAutoSaveTextField(
              controller: _regexController,
              label: '输出提取正则表达式',
              hint: r'Translation:\s*(.+)',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1E40AF).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF3B82F6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提示词模板支持变量：{from} 源语言，{to} 目标语言，{text} 待翻译文本',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
