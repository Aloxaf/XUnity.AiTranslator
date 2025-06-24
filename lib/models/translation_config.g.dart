// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationConfig _$TranslationConfigFromJson(Map<String, dynamic> json) =>
    TranslationConfig(
      serverPort: (json['serverPort'] as num?)?.toInt() ?? 8080,
      promptTemplate:
          json['promptTemplate'] as String? ??
          'Translate the following text from {from} to {to}:\n{text}',
      outputRegex: json['outputRegex'] as String? ?? r'.+',
      concurrency: (json['concurrency'] as num?)?.toInt() ?? 3,
      currentProvider: json['currentProvider'] as String? ?? 'OpenRouter',
      llmProviders: (json['llmProviders'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LLMProviderConfig.fromJson(e as Map<String, dynamic>)),
      ),
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
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.3,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 8192,
      topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$LLMProviderConfigToJson(LLMProviderConfig instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'apiKey': instance.apiKey,
      'model': instance.model,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'topP': instance.topP,
      'frequencyPenalty': instance.frequencyPenalty,
      'presencePenalty': instance.presencePenalty,
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
