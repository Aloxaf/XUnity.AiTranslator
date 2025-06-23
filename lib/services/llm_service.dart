import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/translation_config.dart';

class LLMService {
  final Dio _dio;
  final Logger _logger = Logger();

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
        'HTTP-Referer': 'https://github.com/your-username/xunity-ai-translator',
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
