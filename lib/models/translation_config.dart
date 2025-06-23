import 'package:json_annotation/json_annotation.dart';

part 'translation_config.g.dart';

@JsonSerializable()
class TranslationConfig {
  final int serverPort;
  final String promptTemplate;
  final String outputRegex;
  final int concurrency;
  final LLMServiceConfig llmService;

  const TranslationConfig({
    this.serverPort = 8080,
    this.promptTemplate =
        'Translate the following text from {from} to {to}:\n\n{text}\n\nTranslation:',
    this.outputRegex = r'Translation:\s*(.+)',
    this.concurrency = 3,
    this.llmService = const LLMServiceConfig(),
  });

  factory TranslationConfig.fromJson(Map<String, dynamic> json) =>
      _$TranslationConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationConfigToJson(this);

  TranslationConfig copyWith({
    int? serverPort,
    String? promptTemplate,
    String? outputRegex,
    int? concurrency,
    LLMServiceConfig? llmService,
  }) {
    return TranslationConfig(
      serverPort: serverPort ?? this.serverPort,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      outputRegex: outputRegex ?? this.outputRegex,
      concurrency: concurrency ?? this.concurrency,
      llmService: llmService ?? this.llmService,
    );
  }
}

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
