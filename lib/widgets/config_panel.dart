import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xunity_ai_translator/services/llm_service.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'auto_save_mixin.dart';
import 'common_widgets.dart';

/// 自定义范围限制的TextInputFormatter
class RangeTextInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 允许负号在开头
    if (newValue.text == '-' && min < 0) {
      return newValue;
    }

    // 允许小数点
    if (newValue.text.endsWith('.') &&
        !newValue.text.contains(RegExp(r'\..*\.'))) {
      return newValue;
    }

    // 检查基本数字格式
    final pattern = min < 0 ? r'^-?\d*\.?\d*$' : r'^\d*\.?\d*$';
    if (!RegExp(pattern).hasMatch(newValue.text)) {
      return oldValue;
    }

    // 如果是完整的数字，检查范围
    final value = double.tryParse(newValue.text);
    if (value != null) {
      if (value < min || value > max) {
        return oldValue;
      }
    }

    return newValue;
  }
}

/// API 基础 URL 输入验证器
class BaseUrlTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 如果文本以 / 结尾，移除末尾的 /
    if (newValue.text.endsWith('/') && newValue.text.length > 1) {
      return TextEditingValue(
        text: newValue.text.substring(0, newValue.text.length - 1),
        selection: TextSelection.collapsed(offset: newValue.text.length - 1),
      );
    }

    return newValue;
  }
}

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
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;
  late TextEditingController _topPController;
  late TextEditingController _frequencyPenaltyController;
  late TextEditingController _presencePenaltyController;

  String _selectedProvider = 'OpenRouter';

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
    _promptController = TextEditingController(text: config.promptTemplate);
    _regexController = TextEditingController(text: config.outputRegex);

    final currentConfig = config.currentLLMConfig;
    _baseUrlController = TextEditingController(text: currentConfig.baseUrl);
    _apiKeyController = TextEditingController(text: currentConfig.apiKey);
    _modelController = TextEditingController(text: currentConfig.model);
    _temperatureController = TextEditingController(
      text: currentConfig.temperature.toString(),
    );
    _maxTokensController = TextEditingController(
      text: currentConfig.maxTokens.toString(),
    );
    _topPController = TextEditingController(
      text: currentConfig.topP.toString(),
    );
    _frequencyPenaltyController = TextEditingController(
      text: currentConfig.frequencyPenalty.toString(),
    );
    _presencePenaltyController = TextEditingController(
      text: currentConfig.presencePenalty.toString(),
    );
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

        _temperatureController.text = currentConfig.temperature.toString();
        _maxTokensController.text = currentConfig.maxTokens.toString();
        _topPController.text = currentConfig.topP.toString();
        _frequencyPenaltyController.text = currentConfig.frequencyPenalty
            .toString();
        _presencePenaltyController.text = currentConfig.presencePenalty
            .toString();
      });

      // 模型重新加载现在由ModelNotifier自动处理
    }
  }

  @override
  TranslationConfig createUpdatedConfig(TranslationConfig currentConfig) {
    // 验证并解析数值参数
    double temperature;
    int maxTokens;
    double topP;
    double frequencyPenalty;
    double presencePenalty;

    try {
      temperature = double.parse(_temperatureController.text);
      maxTokens = int.parse(_maxTokensController.text);
      topP = double.parse(_topPController.text);
      frequencyPenalty = double.parse(_frequencyPenaltyController.text);
      presencePenalty = double.parse(_presencePenaltyController.text);
    } catch (e) {
      // 如果解析失败，使用默认值
      temperature = 0.3;
      maxTokens = 8192;
      topP = 1.0;
      frequencyPenalty = 0.0;
      presencePenalty = 0.0;
    }

    // 更新当前提供商的配置
    final updatedProviderConfig = LLMProviderConfig(
      baseUrl: _baseUrlController.text,
      apiKey: _apiKeyController.text,
      model: _modelController.text,
      temperature: temperature,
      maxTokens: maxTokens,
      topP: topP,
      frequencyPenalty: frequencyPenalty,
      presencePenalty: presencePenalty,
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
        aCurrentConfig.model == bCurrentConfig.model &&
        aCurrentConfig.temperature == bCurrentConfig.temperature &&
        aCurrentConfig.maxTokens == bCurrentConfig.maxTokens &&
        aCurrentConfig.topP == bCurrentConfig.topP &&
        aCurrentConfig.frequencyPenalty == bCurrentConfig.frequencyPenalty &&
        aCurrentConfig.presencePenalty == bCurrentConfig.presencePenalty;
  }

  @override
  void dispose() {
    _promptController.dispose();
    _regexController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    _topPController.dispose();
    _frequencyPenaltyController.dispose();
    _presencePenaltyController.dispose();
    super.dispose();
  }

  void _onProviderChanged(String? provider) {
    if (provider != null && provider != _selectedProvider) {
      // 验证并解析数值参数
      double temperature;
      int maxTokens;
      double topP;
      double frequencyPenalty;
      double presencePenalty;

      try {
        temperature = double.parse(_temperatureController.text);
        maxTokens = int.parse(_maxTokensController.text);
        topP = double.parse(_topPController.text);
        frequencyPenalty = double.parse(_frequencyPenaltyController.text);
        presencePenalty = double.parse(_presencePenaltyController.text);
      } catch (e) {
        // 如果解析失败，使用默认值
        temperature = 0.3;
        maxTokens = 8192;
        topP = 1.0;
        frequencyPenalty = 0.0;
        presencePenalty = 0.0;
      }

      // 先保存当前提供商的配置
      final currentConfig = ref.read(configProvider);
      final updatedCurrentProviderConfig = LLMProviderConfig(
        baseUrl: _baseUrlController.text,
        apiKey: _apiKeyController.text,
        model: _modelController.text,
        temperature: temperature,
        maxTokens: maxTokens,
        topP: topP,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
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
        targetConfig = ProviderDefinitions.getDefaultConfig(
          provider,
        ).copyWith(apiKey: targetConfig.apiKey); // 保留已设置的API密钥
      }

      setState(() {
        _selectedProvider = provider;
        _baseUrlController.text = targetConfig.baseUrl;
        _apiKeyController.text = targetConfig.apiKey;
        _modelController.text = targetConfig.model;
        _temperatureController.text = targetConfig.temperature.toString();
        _maxTokensController.text = targetConfig.maxTokens.toString();
        _topPController.text = targetConfig.topP.toString();
        _frequencyPenaltyController.text = targetConfig.frequencyPenalty
            .toString();
        _presencePenaltyController.text = targetConfig.presencePenalty
            .toString();
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

    return SearchableDropdown<ModelInfo>(
      value: _modelController.text,
      items: modelState.models,
      isLoading: modelState.isLoading,
      error: modelState.error,
      onSelected: _onModelSelected,
      onRefresh: () {
        ref.read(modelProvider(_selectedProvider).notifier).refreshModels();
      },
      label: '模型',
      hint: '选择或输入模型名称',
      getItemId: (model) => model.id,
      getItemName: (model) => model.name,
      getItemDescription: (model) => model.description,
    );
  }

  Widget _buildProviderSelector() {
    return SimpleDropdown<String>(
      value: _selectedProvider,
      items: ProviderDefinitions.providerNames,
      onSelected: (value) => _onProviderChanged(value),
      getItemId: (item) => item,
      getItemName: (item) => item,
      label: 'LLM 服务提供商',
      hint: '选择服务提供商',
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
              _buildProviderSelector(),
              const SizedBox(height: AppTheme.spacingLarge),
              buildAutoSaveTextField(
                controller: _baseUrlController,
                label: 'API 基础 URL',
                hint: 'https://openrouter.ai/api/v1',
                inputFormatters: [BaseUrlTextInputFormatter()],
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
              const SizedBox(height: AppTheme.spacingXXLarge),

              // 高级参数配置 - 使用ExpansionTile实现折叠
              ExpansionTile(
                initiallyExpanded: false,
                title: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: AppTheme.primaryColor,
                      size: AppTheme.iconSizeMedium,
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Text(
                      '高级参数配置',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppTheme.spacingLarge,
                      right: AppTheme.spacingLarge,
                      bottom: AppTheme.spacingLarge,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildAutoSaveTextField(
                                controller: _temperatureController,
                                label: 'Temperature',
                                hint: '0.0-2.0，控制输出随机性',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  RangeTextInputFormatter(min: 0.0, max: 2.0),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingLarge),
                            Expanded(
                              child: buildAutoSaveTextField(
                                controller: _maxTokensController,
                                label: 'Max Tokens',
                                hint: '1-32768，最大生成令牌数',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  RangeTextInputFormatter(min: 1, max: 32768),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingLarge),
                            Expanded(
                              child: buildAutoSaveTextField(
                                controller: _topPController,
                                label: 'Top P',
                                hint: '0.0-1.0，控制采样多样性',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  RangeTextInputFormatter(min: 0.0, max: 1.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),
                        Row(
                          children: [
                            Expanded(
                              child: buildAutoSaveTextField(
                                controller: _frequencyPenaltyController,
                                label: 'Frequency Penalty',
                                hint: '-2.0到2.0，减少重复内容',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                inputFormatters: [
                                  RangeTextInputFormatter(min: -2.0, max: 2.0),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingLarge),
                            Expanded(
                              child: buildAutoSaveTextField(
                                controller: _presencePenaltyController,
                                label: 'Presence Penalty',
                                hint: '-2.0到2.0，鼓励新话题',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                inputFormatters: [
                                  RangeTextInputFormatter(min: -2.0, max: 2.0),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingLarge),
                            const Expanded(child: SizedBox()), // 占位符以保持对齐
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),
                        InfoBox.info(
                          message:
                              'Temperature 控制输出随机性，Top P 控制采样多样性，Penalty 参数用于减少重复和鼓励新内容',
                        ),
                      ],
                    ),
                  ),
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
