import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import 'llm_service.dart';

class EnhancedTranslationService {
  final LLMService _llmService;
  final Logger _logger = Logger();
  final Ref _ref;

  TranslationConfig _config;
  final List<Completer<void>> _activeRequests = [];

  EnhancedTranslationService(this._llmService, this._config, this._ref);

  void updateConfig(TranslationConfig config) {
    _config = config;
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    final logId = _generateLogId();
    final startTime = DateTime.now();

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

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // 记录成功日志
      final log = TranslationLog(
        id: logId,
        timestamp: startTime,
        from: from,
        to: to,
        originalText: text,
        translatedText: result,
        duration: duration,
        isSuccess: true,
      );

      _ref.read(translationLogsProvider.notifier).addLog(log);

      return result;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // 记录失败日志
      final log = TranslationLog(
        id: logId,
        timestamp: startTime,
        from: from,
        to: to,
        originalText: text,
        translatedText: '',
        duration: duration,
        isSuccess: false,
        error: e.toString(),
      );

      _ref.read(translationLogsProvider.notifier).addLog(log);

      rethrow;
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

  String _generateLogId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      16,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  int get activeRequestsCount => _activeRequests.length;
  int get maxConcurrency => _config.concurrency;
}
