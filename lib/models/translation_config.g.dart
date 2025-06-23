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
  llmService: json['llmService'] == null
      ? const LLMServiceConfig()
      : LLMServiceConfig.fromJson(json['llmService'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TranslationConfigToJson(TranslationConfig instance) =>
    <String, dynamic>{
      'serverPort': instance.serverPort,
      'promptTemplate': instance.promptTemplate,
      'outputRegex': instance.outputRegex,
      'concurrency': instance.concurrency,
      'llmService': instance.llmService,
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
