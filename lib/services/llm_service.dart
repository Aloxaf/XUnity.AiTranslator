import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/translation_config.dart';

class LLMService {
  final Dio _dio;
  final Logger _logger = Logger();
  static final Map<String, List<ModelInfo>> _modelCache = {};

  LLMService() : _dio = _configureDio();

  static Dio _configureDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (object) {
          Logger().d(object);
        },
      ),
    );

    return dio;
  }

  Future<List<ModelInfo>> getModels(LLMServiceConfig config) async {
    final cacheKey = '${config.provider}_${config.baseUrl}';

    // 检查缓存
    if (_modelCache.containsKey(cacheKey)) {
      return _modelCache[cacheKey]!;
    }

    if (config.apiKey.isEmpty) {
      throw ArgumentError('API key is required to fetch models');
    }

    try {
      final headers = <String, String>{
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      };

      if (config.provider == 'OpenRouter') {
        headers.addAll({
          'HTTP-Referer': 'https://github.com/Aloxaf/XUnity.AiTranslator',
          'X-Title': 'XUnity AI Translator',
        });
      }

      final response = await _dio.get(
        '${config.baseUrl}/models',
        options: Options(headers: headers),
      );

      final models = _parseModelsResponse(response.data, config.provider);

      // 缓存结果
      _modelCache[cacheKey] = models;

      _logger.i(
        'Successfully fetched ${models.length} models for ${config.provider}',
      );
      return models;
    } on DioException catch (e) {
      _logger.e('Failed to fetch models: ${e.message}');
      throw ModelFetchException('Failed to fetch models: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error fetching models: $e');
      throw ModelFetchException('Unexpected error: ${e.toString()}');
    }
  }

  List<ModelInfo> _parseModelsResponse(dynamic data, String provider) {
    if (data == null || data is! Map<String, dynamic>) {
      throw ModelFetchException('Invalid response format');
    }

    final modelsData = data['data'] as List?;
    if (modelsData == null) {
      throw ModelFetchException('No models data in response');
    }

    final models = <ModelInfo>[];
    for (final modelData in modelsData) {
      if (modelData is Map<String, dynamic>) {
        try {
          final modelInfo = ModelInfo.fromJson(modelData);
          // 过滤掉一些不适合翻译的模型
          if (_isTranslationCapableModel(modelInfo)) {
            models.add(modelInfo);
          }
        } catch (e) {
          _logger.w('Failed to parse model data: $e');
          continue;
        }
      }
    }

    // 按名称排序
    models.sort((a, b) => a.id.compareTo(b.id));
    return models;
  }

  bool _isTranslationCapableModel(ModelInfo model) {
    // 过滤掉明显不适合翻译的模型
    final id = model.id.toLowerCase();

    // 排除图像、音频、嵌入模型
    if (id.contains('vision') ||
        id.contains('audio') ||
        id.contains('whisper') ||
        id.contains('embedding') ||
        id.contains('tts') ||
        id.contains('dall-e') ||
        id.contains('moderation')) {
      return false;
    }

    return true;
  }

  void clearModelCache([String? provider]) {
    if (provider != null) {
      _modelCache.removeWhere((key, value) => key.startsWith(provider));
    } else {
      _modelCache.clear();
    }
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
    required LLMServiceConfig config,
    required String promptTemplate,
    required String outputRegex,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Translation text cannot be empty');
    }

    if (config.apiKey.isEmpty) {
      throw ArgumentError('API key is required');
    }

    try {
      final prompt = _buildPrompt(
        template: promptTemplate,
        from: from,
        to: to,
        text: text,
      );

      final response = await _makeRequest(config, prompt);
      final content = _extractContent(response);
      final translatedText = _extractTranslation(content, outputRegex);

      _logger.i('Translation completed successfully');
      return translatedText;
    } on DioException catch (e) {
      _logger.e('Network error during translation: ${e.message}');
      throw TranslationException('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Translation failed: $e');
      throw TranslationException('Translation failed: ${e.toString()}');
    }
  }

  String _buildPrompt({
    required String template,
    required String from,
    required String to,
    required String text,
  }) {
    return template
        .replaceAll('{from}', from)
        .replaceAll('{to}', to)
        .replaceAll('{text}', text);
  }

  Future<Response> _makeRequest(LLMServiceConfig config, String prompt) async {
    final headers = <String, String>{
      'Authorization': 'Bearer ${config.apiKey}',
      'Content-Type': 'application/json',
    };

    if (config.provider == 'OpenRouter') {
      headers.addAll({
        'HTTP-Referer': 'https://github.com/Aloxaf/XUnity.AiTranslator',
        'X-Title': 'XUnity AI Translator',
      });
    }

    return await _dio.post(
      '${config.baseUrl}/chat/completions',
      options: Options(headers: headers),
      data: {
        'model': config.model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1000,
        'temperature': 0.3,
      },
    );
  }

  String _extractContent(Response response) {
    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw TranslationException('Invalid response format');
    }

    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw TranslationException('No translation choices received');
    }

    final firstChoice = choices[0] as Map<String, dynamic>?;
    if (firstChoice == null) {
      throw TranslationException('Invalid choice format');
    }

    final message = firstChoice['message'] as Map<String, dynamic>?;
    if (message == null) {
      throw TranslationException('Invalid message format');
    }

    final content = message['content'] as String?;
    if (content == null) {
      throw TranslationException('No content in response');
    }

    return content;
  }

  String _extractTranslation(String content, String outputRegex) {
    try {
      final regex = RegExp(outputRegex, multiLine: true, dotAll: true);
      final match = regex.firstMatch(content);

      if (match != null && match.groupCount > 0) {
        final extracted = match.group(1)?.trim();
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }

      // 如果正则表达式没有匹配或匹配结果为空，返回完整内容
      final trimmedContent = content.trim();
      if (trimmedContent.isEmpty) {
        throw TranslationException('Empty translation result');
      }

      return trimmedContent;
    } catch (e) {
      _logger.w('Invalid regex pattern: $outputRegex, error: $e');
      return content.trim();
    }
  }

  void dispose() {
    _dio.close();
  }
}

class TranslationException implements Exception {
  final String message;

  const TranslationException(this.message);

  @override
  String toString() => 'TranslationException: $message';
}

class ModelInfo {
  final String id;
  final String? displayName;
  final String? description;
  final List<String>? tags;

  const ModelInfo({
    required this.id,
    this.displayName,
    this.description,
    this.tags,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      displayName: json['name'] as String? ?? json['id'] as String,
      description: json['description'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  String get name => displayName ?? id;
}

class ModelFetchException implements Exception {
  final String message;

  const ModelFetchException(this.message);

  @override
  String toString() => 'ModelFetchException: $message';
}
