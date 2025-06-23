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
        model: 'anthropic/claude-3.5-sonnet',
      ),
      'OpenAI': LLMProviderConfig(
        baseUrl: 'https://api.openai.com/v1',
        apiKey: '',
        model: 'gpt-4',
      ),
      'Azure OpenAI': LLMProviderConfig(
        baseUrl: 'https://your-resource.openai.azure.com',
        apiKey: '',
        model: 'gpt-4',
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

  const LLMProviderConfig({
    this.baseUrl = '',
    this.apiKey = '',
    this.model = '',
  });

  factory LLMProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$LLMProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LLMProviderConfigToJson(this);

  LLMProviderConfig copyWith({String? baseUrl, String? apiKey, String? model}) {
    return LLMProviderConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
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

  const LLMServiceConfig({
    this.provider = 'OpenRouter',
    this.baseUrl = 'https://openrouter.ai/api/v1',
    this.apiKey = '',
    this.model = 'anthropic/claude-3.5-sonnet',
  });

  factory LLMServiceConfig.fromJson(Map<String, dynamic> json) =>
      _$LLMServiceConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LLMServiceConfigToJson(this);

  LLMServiceConfig copyWith({
    String? provider,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    return LLMServiceConfig(
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
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
