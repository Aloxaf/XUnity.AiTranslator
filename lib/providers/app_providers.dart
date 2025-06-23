import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/translation_config.dart';
import '../services/llm_service.dart';
import '../services/enhanced_translation_service.dart';
import '../services/http_server.dart';
import 'package:flutter/foundation.dart';

// 配置提供者
final configProvider = StateNotifierProvider<ConfigNotifier, TranslationConfig>(
  (ref) => ConfigNotifier(),
);

class ConfigNotifier extends StateNotifier<TranslationConfig> {
  static const String _configKey = 'translation_config';
  bool _isLoading = false;

  ConfigNotifier() : super(const TranslationConfig()) {
    _loadConfig();
  }

  bool get isLoading => _isLoading;

  Future<void> _loadConfig() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);

      if (configJson != null && configJson.isNotEmpty) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        final loadedConfig = TranslationConfig.fromJson(configMap);

        if (mounted) {
          state = loadedConfig;
        }
      }
    } catch (e) {
      // 加载失败时使用默认配置，不抛出异常
      debugPrint('Failed to load config: $e, using default configuration');
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateConfig(TranslationConfig config) async {
    if (!mounted) return false;

    state = config;
    return await _saveConfig();
  }

  Future<bool> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(state.toJson());
      final success = await prefs.setString(_configKey, configJson);

      if (success) {
        debugPrint('Configuration saved successfully');
      }

      return success;
    } catch (e) {
      debugPrint('Failed to save config: $e');
      return false;
    }
  }
}

// 翻译日志提供者
final translationLogsProvider =
    StateNotifierProvider<TranslationLogsNotifier, List<TranslationLog>>((ref) {
      return TranslationLogsNotifier();
    });

class TranslationLogsNotifier extends StateNotifier<List<TranslationLog>> {
  static const int _maxLogCount = 100;

  TranslationLogsNotifier() : super([]);

  void addLog(TranslationLog log) {
    if (!mounted) return;

    state = [log, ...state];

    // 保持最多 _maxLogCount 条记录
    if (state.length > _maxLogCount) {
      state = state.take(_maxLogCount).toList();
    }
  }

  void clearLogs() {
    if (!mounted) return;
    state = [];
  }

  List<TranslationLog> getRecentLogs(int count) {
    return state.take(count).toList();
  }

  List<TranslationLog> getSuccessfulLogs() {
    return state.where((log) => log.isSuccess).toList();
  }

  List<TranslationLog> getFailedLogs() {
    return state.where((log) => !log.isSuccess).toList();
  }
}

// 服务提供者
final llmServiceProvider = Provider<LLMService>((ref) {
  final service = LLMService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

final translationServiceProvider = Provider<EnhancedTranslationService>((ref) {
  final llmService = ref.watch(llmServiceProvider);
  final config = ref.watch(configProvider);
  return EnhancedTranslationService(llmService, config, ref);
});

final httpServerProvider = Provider<HttpTranslationServer>((ref) {
  final translationService = ref.watch(translationServiceProvider);
  final server = HttpTranslationServer(translationService);

  ref.onDispose(() async {
    if (server.isRunning) {
      await server.stop();
    }
  });

  return server;
});

// 服务器状态提供者
final serverStateProvider =
    StateNotifierProvider<ServerStateNotifier, ServerState>((ref) {
      final httpServer = ref.watch(httpServerProvider);
      return ServerStateNotifier(httpServer);
    });

class ServerState {
  final bool isRunning;
  final int? port;
  final String? error;
  final DateTime? lastStartTime;

  const ServerState({
    this.isRunning = false,
    this.port,
    this.error,
    this.lastStartTime,
  });

  ServerState copyWith({
    bool? isRunning,
    int? port,
    String? error,
    DateTime? lastStartTime,
  }) {
    return ServerState(
      isRunning: isRunning ?? this.isRunning,
      port: port ?? this.port,
      error: error,
      lastStartTime: lastStartTime ?? this.lastStartTime,
    );
  }

  Duration? get uptime {
    if (!isRunning || lastStartTime == null) return null;
    return DateTime.now().difference(lastStartTime!);
  }
}

class ServerStateNotifier extends StateNotifier<ServerState> {
  final HttpTranslationServer _httpServer;

  ServerStateNotifier(this._httpServer) : super(const ServerState());

  Future<void> startServer(int port) async {
    if (state.isRunning) {
      return;
    }

    try {
      await _httpServer.start(port);

      if (mounted) {
        state = ServerState(
          isRunning: true,
          port: port,
          lastStartTime: DateTime.now(),
        );
      }
    } catch (e) {
      if (mounted) {
        state = ServerState(isRunning: false, error: e.toString());
      }
      rethrow;
    }
  }

  Future<void> stopServer() async {
    if (!state.isRunning) {
      return;
    }

    try {
      await _httpServer.stop();

      if (mounted) {
        state = const ServerState(isRunning: false);
      }
    } catch (e) {
      if (mounted) {
        state = ServerState(isRunning: false, error: e.toString());
      }
      rethrow;
    }
  }

  void clearError() {
    if (state.error != null && mounted) {
      state = state.copyWith(error: null);
    }
  }
}
