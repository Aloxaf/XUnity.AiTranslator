// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationConfig _$TranslationConfigFromJson(
  Map<String, dynamic> json,
) => TranslationConfig(
  serverPort: (json['serverPort'] as num?)?.toInt() ?? 8080,
  promptTemplate:
      json['promptTemplate'] as String? ??
      'Translate the following text from {from} to {to}:\n\n{text}\n\nTranslation:',
  outputRegex: json['outputRegex'] as String? ?? r'Translation:\s*(.+)',
  concurrency: (json['concurrency'] as num?)?.toInt() ?? 3,
  currentProvider: json['currentProvider'] as String? ?? 'OpenRouter',
  llmProviders:
      (json['llmProviders'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LLMProviderConfig.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {
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
);

Map<String, dynamic> _$TranslationConfigToJson(TranslationConfig instance) =>
    <String, dynamic>{
      'serverPort': instance.serverPort,
      'promptTemplate': instance.promptTemplate,
      'outputRegex': instance.outputRegex,
      'concurrency': instance.concurrency,
      'currentProvider': instance.currentProvider,
      'llmProviders': instance.llmProviders,
    };

LLMProviderConfig _$LLMProviderConfigFromJson(Map<String, dynamic> json) =>
    LLMProviderConfig(
      baseUrl: json['baseUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? '',
    );

Map<String, dynamic> _$LLMProviderConfigToJson(LLMProviderConfig instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'model': instance.model,
    };

LLMServiceConfig _$LLMServiceConfigFromJson(Map<String, dynamic> json) =>
    LLMServiceConfig(
      provider: json['provider'] as String? ?? 'OpenRouter',
      baseUrl: json['baseUrl'] as String? ?? 'https://openrouter.ai/api/v1',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'anthropic/claude-3.5-sonnet',
    );

Map<String, dynamic> _$LLMServiceConfigToJson(LLMServiceConfig instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'model': instance.model,
    };

TranslationLog _$TranslationLogFromJson(Map<String, dynamic> json) =>
    TranslationLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      from: json['from'] as String,
      to: json['to'] as String,
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      isSuccess: json['isSuccess'] as bool,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$TranslationLogToJson(TranslationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'from': instance.from,
      'to': instance.to,
      'originalText': instance.originalText,
      'translatedText': instance.translatedText,
      'duration': instance.duration.inMicroseconds,
      'isSuccess': instance.isSuccess,
      'error': instance.error,
    };
