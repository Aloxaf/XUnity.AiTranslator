import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart' show TranslationConfig, TranslationLog, ContextLimitType;
import '../providers/app_providers.dart';
import 'llm_service.dart';

class EnhancedTranslationService {
  final LLMService _llmService;
  final Ref _ref;

  TranslationConfig _config;
  final List<_ConcurrencySlot> _activeRequests = [];
  // Ring buffer of "original → translated" pairs for {context} injection.
  // Stored as "original\ttranslated" to keep it simple.
  final List<String> _contextBuffer = [];
  bool _disposed = false;

  EnhancedTranslationService(this._llmService, this._config, this._ref);

  void updateConfig(TranslationConfig config) {
    if (_disposed) return;
    _config = config;
    _trimContext();
  }

  /// Returns the current context string to substitute for {context}.
  /// Each past translation is one line: "original → translated".
  String _buildContext() {
    final limit = _config.contextLimit;
    if (limit <= 0) return '';

    final lines = switch (_config.contextLimitType) {
      ContextLimitType.byCount => _contextBuffer.length <= limit
          ? List<String>.from(_contextBuffer)
          : _contextBuffer.sublist(_contextBuffer.length - limit),
      ContextLimitType.byChars => _contextByChars(limit),
    };
    return lines.join('\n');
  }

  List<String> _contextByChars(int maxChars) {
    final result = <String>[];
    int total = 0;
    for (final entry in _contextBuffer.reversed) {
      final len = entry.length + 1; // +1 for newline
      if (total + len > maxChars) break;
      result.add(entry);
      total += len;
    }
    return result.reversed.toList();
  }

  void _addToContext(String original, String translated) {
    _contextBuffer.add('$original\t$translated');
    _trimContext();
  }

  void _trimContext() {
    final limit = _config.contextLimit;
    if (limit <= 0) {
      _contextBuffer.clear();
      return;
    }
    if (_config.contextLimitType == ContextLimitType.byCount) {
      while (_contextBuffer.length > limit) {
        _contextBuffer.removeAt(0);
      }
    }
    // For byChars we don't pre-trim; _contextByChars handles it at read time.
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (_disposed) {
      throw StateError('Service has been disposed');
    }

    if (text.trim().isEmpty) {
      throw ArgumentError('Translation text cannot be empty');
    }

    final logId = _generateLogId();
    final startTime = DateTime.now();

    // 等待并发槽位
    final slot = await _acquireSlot();

    try {
      final result = await _llmService.translate(
        text: text,
        from: from,
        to: to,
        provider: _config.currentProvider,
        config: _config.currentLLMConfig,
        promptTemplate: _config.promptTemplate,
        outputRegex: _config.outputRegex,
        context: _buildContext(),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _addToContext(text, result);

      // 记录成功日志
      _addLog(
        TranslationLog(
          id: logId,
          timestamp: startTime,
          from: from,
          to: to,
          originalText: text,
          translatedText: result,
          duration: duration,
          isSuccess: true,
        ),
      );

      return result;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // 记录失败日志
      _addLog(
        TranslationLog(
          id: logId,
          timestamp: startTime,
          from: from,
          to: to,
          originalText: text,
          translatedText: '',
          duration: duration,
          isSuccess: false,
          error: e.toString(),
        ),
      );

      rethrow;
    } finally {
      _releaseSlot(slot);
    }
  }

  Future<_ConcurrencySlot> _acquireSlot() async {
    while (_activeRequests.length >= _config.concurrency) {
      if (_disposed) {
        throw StateError('Service has been disposed');
      }

      // 等待任意一个请求完成
      if (_activeRequests.isNotEmpty) {
        final completers = _activeRequests.map((slot) => slot.completer.future);
        await Future.any(completers);
      }
    }

    final slot = _ConcurrencySlot();
    _activeRequests.add(slot);
    return slot;
  }

  void _releaseSlot(_ConcurrencySlot slot) {
    _activeRequests.remove(slot);
    slot.completer.complete();
  }

  void _addLog(TranslationLog log) {
    if (!_disposed && _ref.read(translationLogsProvider.notifier).mounted) {
      _ref.read(translationLogsProvider.notifier).addLog(log);
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

  void dispose() {
    if (_disposed) return;

    _disposed = true;

    // 完成所有待处理的请求
    for (final slot in _activeRequests) {
      if (!slot.completer.isCompleted) {
        slot.completer.complete();
      }
    }
    _activeRequests.clear();
  }

  int get activeRequestsCount => _activeRequests.length;
  int get maxConcurrency => _config.concurrency;
  bool get isDisposed => _disposed;
}

class _ConcurrencySlot {
  final Completer<void> completer = Completer<void>();
}
