import 'package:json_annotation/json_annotation.dart';

part 'translation_config.g.dart';

// Provider 配置集中管理
class ProviderDefinitions {
  static const Map<String, ProviderDefinition> definitions = {
    'OpenRouter': ProviderDefinition(
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      defaultModel: 'google/gemini-2.0-flash-001',
    ),
    'OpenAI': ProviderDefinition(
      name: 'OpenAI',
      baseUrl: 'https://api.openai.com/v1',
      defaultModel: 'gpt-4.1-mini',
    ),
    'DeepSeek': ProviderDefinition(
      name: 'DeepSeek',
      baseUrl: 'https://api.deepseek.com/v1',
      defaultModel: 'deepseek-chat',
    ),
    'Google AI Studio': ProviderDefinition(
      name: 'Google AI Studio',
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
      defaultModel: 'gemini-2.0-flash',
    ),
    '自定义': ProviderDefinition(name: '自定义', baseUrl: '', defaultModel: ''),
  };

  /// 获取所有Provider名称列表
  static List<String> get providerNames => definitions.keys.toList();

  /// 获取Provider的默认配置
  static LLMProviderConfig getDefaultConfig(String providerName) {
    final definition = definitions[providerName];
    if (definition == null) {
      throw ArgumentError('Unknown provider: $providerName');
    }
    return definition.toConfig();
  }

  /// 获取默认的Provider Map
  static Map<String, LLMProviderConfig> get defaultProviderMap {
    return definitions.map(
      (key, definition) => MapEntry(key, definition.toConfig()),
    );
  }
}

class ProviderDefinition {
  final String name;
  final String baseUrl;
  final String defaultModel;
  final double defaultTemperature;
  final int defaultMaxTokens;
  final double defaultTopP;
  final double defaultFrequencyPenalty;
  final double defaultPresencePenalty;

  const ProviderDefinition({
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
    this.defaultTemperature = 0.3,
    this.defaultMaxTokens = 8192,
    this.defaultTopP = 1.0,
    this.defaultFrequencyPenalty = 0.0,
    this.defaultPresencePenalty = 0.0,
  });

  LLMProviderConfig toConfig({String? apiKey}) {
    return LLMProviderConfig(
      baseUrl: baseUrl,
      apiKey: apiKey ?? '',
      model: defaultModel,
      temperature: defaultTemperature,
      maxTokens: defaultMaxTokens,
      topP: defaultTopP,
      frequencyPenalty: defaultFrequencyPenalty,
      presencePenalty: defaultPresencePenalty,
    );
  }
}

@JsonSerializable()
class TranslationConfig {
  final int serverPort;
  final String promptTemplate;
  final String outputRegex;
  final int concurrency;
  final String currentProvider;
  final Map<String, LLMProviderConfig> llmProviders;

  const TranslationConfig({
    this.serverPort = 8080,
    this.promptTemplate =
        'Translate the following text from {from} to {to} without any explanation:\n{text}',
    this.outputRegex = r'.+',
    this.concurrency = 3,
    this.currentProvider = 'OpenRouter',
    Map<String, LLMProviderConfig>? llmProviders,
  }) : llmProviders = llmProviders ?? const {};

  // 使用工厂方法创建默认配置
  factory TranslationConfig.defaultConfig() {
    return TranslationConfig(
      llmProviders: ProviderDefinitions.defaultProviderMap,
    );
  }

  factory TranslationConfig.fromJson(Map<String, dynamic> json) =>
      _$TranslationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationConfigToJson(this);

  // 获取当前选中的LLM服务配置
  LLMProviderConfig get currentLLMConfig {
    return llmProviders[currentProvider] ??
        ProviderDefinitions.getDefaultConfig(currentProvider);
  }

  TranslationConfig copyWith({
    int? serverPort,
    String? promptTemplate,
    String? outputRegex,
    int? concurrency,
    String? currentProvider,
    Map<String, LLMProviderConfig>? llmProviders,
  }) {
    return TranslationConfig(
      serverPort: serverPort ?? this.serverPort,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      outputRegex: outputRegex ?? this.outputRegex,
      concurrency: concurrency ?? this.concurrency,
      currentProvider: currentProvider ?? this.currentProvider,
      llmProviders: llmProviders ?? this.llmProviders,
    );
  }

  // 更新特定提供商的配置
  TranslationConfig updateProviderConfig(
    String provider,
    LLMProviderConfig config,
  ) {
    final updatedProviders = Map<String, LLMProviderConfig>.from(llmProviders);
    updatedProviders[provider] = config;

    return copyWith(llmProviders: updatedProviders);
  }

  // 切换当前提供商
  TranslationConfig switchProvider(String provider) {
    return copyWith(currentProvider: provider);
  }
}

@JsonSerializable()
class LLMProviderConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;

  const LLMProviderConfig({
    this.baseUrl = '',
    this.apiKey = '',
    this.model = '',
    this.temperature = 0.3,
    this.maxTokens = 8192,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
  });

  factory LLMProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$LLMProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LLMProviderConfigToJson(this);

  LLMProviderConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
  }) {
    return LLMProviderConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
    );
  }
}

@JsonSerializable()
class TranslationLog {
  final String id;
  final DateTime timestamp;
  final String from;
  final String to;
  final String originalText;
  final String translatedText;
  final Duration duration;
  final bool isSuccess;
  final String? error;

  const TranslationLog({
    required this.id,
    required this.timestamp,
    required this.from,
    required this.to,
    required this.originalText,
    required this.translatedText,
    required this.duration,
    required this.isSuccess,
    this.error,
  });

  factory TranslationLog.fromJson(Map<String, dynamic> json) =>
      _$TranslationLogFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationLogToJson(this);
}
