import 'dart:async';
import 'package:logger/logger.dart';
import '../models/translation_config.dart';
import 'llm_service.dart';

class TranslationService {
  final LLMService _llmService;
  final Logger _logger = Logger();

  TranslationConfig _config;
  final List<Completer<void>> _activeRequests = [];

  TranslationService(this._llmService, this._config);

  void updateConfig(TranslationConfig config) {
    _config = config;
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    // 等待并发槽位
    await _waitForSlot();

    final completer = Completer<void>();
    _activeRequests.add(completer);

    try {
      final result = await _llmService.translate(
        text: text,
        from: from,
        to: to,
        config: _config.llmService,
        promptTemplate: _config.promptTemplate,
        outputRegex: _config.outputRegex,
      );

      return result;
    } finally {
      _activeRequests.remove(completer);
      completer.complete();
    }
  }

  Future<void> _waitForSlot() async {
    while (_activeRequests.length >= _config.concurrency) {
      // 等待任意一个请求完成
      if (_activeRequests.isNotEmpty) {
        await Future.any(_activeRequests.map((c) => c.future));
      }
    }
  }

  int get activeRequestsCount => _activeRequests.length;
  int get maxConcurrency => _config.concurrency;
}
