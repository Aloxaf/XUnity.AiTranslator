import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/translation_config.dart';
import '../services/llm_service.dart';
import '../services/enhanced_translation_service.dart';
import '../services/http_server.dart';

// 配置提供者
final configProvider = StateNotifierProvider<ConfigNotifier, TranslationConfig>(
  (ref) {
    return ConfigNotifier();
  },
);

class ConfigNotifier extends StateNotifier<TranslationConfig> {
  ConfigNotifier() : super(const TranslationConfig()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('translation_config');
      if (configJson != null && configJson.isNotEmpty) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        final loadedConfig = TranslationConfig.fromJson(configMap);
        state = loadedConfig;
        print('配置已从持久化存储加载');
      } else {
        print('未找到保存的配置，使用默认配置');
      }
    } catch (e) {
      print('加载配置失败: $e，使用默认配置');
    }
  }

  Future<void> updateConfig(TranslationConfig config) async {
    state = config;
    await _saveConfig();
  }

  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(state.toJson());
      await prefs.setString('translation_config', configJson);
      print('配置已保存到持久化存储');
    } catch (e) {
      print('保存配置失败: $e');
    }
  }
}

// 翻译日志提供者
final translationLogsProvider =
    StateNotifierProvider<TranslationLogsNotifier, List<TranslationLog>>((ref) {
      return TranslationLogsNotifier();
    });

class TranslationLogsNotifier extends StateNotifier<List<TranslationLog>> {
  TranslationLogsNotifier() : super([]);

  void addLog(TranslationLog log) {
    state = [log, ...state];
    // 保持最多 100 条记录
    if (state.length > 100) {
      state = state.take(100).toList();
    }
  }

  void clearLogs() {
    state = [];
  }
}

// 服务提供者
final llmServiceProvider = Provider<LLMService>((ref) {
  return LLMService();
});

final translationServiceProvider = Provider<EnhancedTranslationService>((ref) {
  final llmService = ref.watch(llmServiceProvider);
  final config = ref.watch(configProvider);
  return EnhancedTranslationService(llmService, config, ref);
});

final httpServerProvider = Provider<HttpTranslationServer>((ref) {
  final translationService = ref.watch(translationServiceProvider);
  return HttpTranslationServer(translationService);
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

  const ServerState({this.isRunning = false, this.port, this.error});

  ServerState copyWith({bool? isRunning, int? port, String? error}) {
    return ServerState(
      isRunning: isRunning ?? this.isRunning,
      port: port ?? this.port,
      error: error ?? this.error,
    );
  }
}

class ServerStateNotifier extends StateNotifier<ServerState> {
  final HttpTranslationServer _httpServer;

  ServerStateNotifier(this._httpServer) : super(const ServerState());

  Future<void> startServer(int port) async {
    try {
      await _httpServer.start(port);
      state = ServerState(isRunning: true, port: port);
    } catch (e) {
      state = ServerState(isRunning: false, error: e.toString());
    }
  }

  Future<void> stopServer() async {
    try {
      await _httpServer.stop();
      state = const ServerState(isRunning: false);
    } catch (e) {
      state = ServerState(isRunning: false, error: e.toString());
    }
  }
}
