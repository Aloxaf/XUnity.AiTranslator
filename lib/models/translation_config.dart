import 'package:json_annotation/json_annotation.dart';

part 'translation_config.g.dart';

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
        'Translate the following text from {from} to {to}:\n\n{text}\n\nTranslation:',
    this.outputRegex = r'Translation:\s*(.+)',
    this.concurrency = 3,
    this.currentProvider = 'OpenRouter',
    this.llmProviders = const {
      'OpenRouter': LLMProviderConfig(
        baseUrl: 'https://openrouter.ai/api/v1',
        apiKey: '',
        model: 'google/gemini-2.0-flash-001',
      ),
      'OpenAI': LLMProviderConfig(
        baseUrl: 'https://api.openai.com/v1',
        apiKey: '',
        model: 'gpt-4.1-mini',
      ),
      'Azure OpenAI': LLMProviderConfig(
        baseUrl: 'https://your-resource.openai.azure.com',
        apiKey: '',
        model: 'gpt-4.1-mini',
      ),
      '自定义': LLMProviderConfig(baseUrl: '', apiKey: '', model: ''),
    },
  });

  factory TranslationConfig.fromJson(Map<String, dynamic> json) =>
      _$TranslationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationConfigToJson(this);

  // 获取当前选中的LLM服务配置
  LLMProviderConfig get currentLLMConfig {
    return llmProviders[currentProvider] ??
        llmProviders['OpenRouter'] ??
        const LLMProviderConfig();
  }

  // 获取适配旧版本的LLMServiceConfig
  LLMServiceConfig get llmService {
    final currentConfig = currentLLMConfig;
    return LLMServiceConfig(
      provider: currentProvider,
      baseUrl: currentConfig.baseUrl,
      apiKey: currentConfig.apiKey,
      model: currentConfig.model,
      temperature: currentConfig.temperature,
      maxTokens: currentConfig.maxTokens,
      topP: currentConfig.topP,
      frequencyPenalty: currentConfig.frequencyPenalty,
      presencePenalty: currentConfig.presencePenalty,
    );
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

// 保持向后兼容性的类
@JsonSerializable()
class LLMServiceConfig {
  final String provider;
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;

  const LLMServiceConfig({
    this.provider = 'OpenRouter',
    this.baseUrl = 'https://openrouter.ai/api/v1',
    this.apiKey = '',
    this.model = 'google/gemini-2.0-flash-001',
    this.temperature = 0.3,
    this.maxTokens = 8192,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
  });

  factory LLMServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$LLMServiceConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LLMServiceConfigToJson(this);

  LLMServiceConfig copyWith({
    String? provider,
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
  }) {
    return LLMServiceConfig(
      provider: provider ?? this.provider,
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
