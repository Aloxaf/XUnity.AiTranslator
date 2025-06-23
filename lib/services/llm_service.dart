import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/translation_config.dart';

class LLMService {
  final Dio _dio;
  final Logger _logger = Logger();

  LLMService() : _dio = Dio();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
    required LLMServiceConfig config,
    required String promptTemplate,
    required String outputRegex,
  }) async {
    try {
      final prompt = promptTemplate
          .replaceAll('{from}', from)
          .replaceAll('{to}', to)
          .replaceAll('{text}', text);

      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            if (config.provider == 'OpenRouter')
              'HTTP-Referer':
                  'https://github.com/your-username/xunity-ai-translator',
            if (config.provider == 'OpenRouter')
              'X-Title': 'XUnity AI Translator',
          },
        ),
        data: {
          'model': config.model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        },
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;

      // 使用正则表达式提取翻译结果
      final regex = RegExp(outputRegex, multiLine: true, dotAll: true);
      final match = regex.firstMatch(content);

      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim() ?? content.trim();
      }

      // 如果正则表达式没有匹配，返回完整内容
      return content.trim();
    } catch (e) {
      _logger.e('Translation failed: $e');
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
  }
}
