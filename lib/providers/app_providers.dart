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

  ConfigNotifier() : super(TranslationConfig.defaultConfig()) {
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

        // 新版本配置
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
  final initialConfig = ref.read(configProvider);
  final service = EnhancedTranslationService(llmService, initialConfig, ref);

  // 监听配置变更并更新服务配置
  ref.listen<TranslationConfig>(configProvider, (previous, next) {
    if (previous != next) {
      service.updateConfig(next);
    }
  });

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

final httpServerProvider = Provider<HttpTranslationServer>((ref) {
  final translationService = ref.read(translationServiceProvider);
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
      final httpServer = ref.read(httpServerProvider);
      final notifier = ServerStateNotifier(httpServer);

      // 监听配置变更，智能重启服务器
      ref.listen<TranslationConfig>(configProvider, (previous, next) {
        if (previous != next) {
          notifier.handleConfigChange(next);
        }
      });

      return notifier;
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
  TranslationConfig? _lastConfig;

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

  /// 处理配置变更，智能决定是否需要重启服务
  Future<void> handleConfigChange(TranslationConfig newConfig) async {
    if (_lastConfig == null) {
      _lastConfig = newConfig;
      return;
    }

    final oldConfig = _lastConfig!;
    _lastConfig = newConfig;

    // 如果服务未运行，则不需要处理
    if (!state.isRunning) {
      return;
    }

    // 检查是否需要重启HTTP服务的配置项
    final needsRestart = _needsServerRestart(oldConfig, newConfig);

    if (needsRestart) {
      try {
        // 重启服务器
        await _httpServer.stop();
        await _httpServer.start(newConfig.serverPort);

        if (mounted) {
          state = ServerState(
            isRunning: true,
            port: newConfig.serverPort,
            lastStartTime: DateTime.now(),
          );
        }
      } catch (e) {
        if (mounted) {
          state = ServerState(isRunning: false, error: e.toString());
        }
      }
    }
  }

  /// 判断配置变更是否需要重启HTTP服务
  bool _needsServerRestart(
    TranslationConfig oldConfig,
    TranslationConfig newConfig,
  ) {
    // 端口变更需要重启
    if (oldConfig.serverPort != newConfig.serverPort) {
      return true;
    }

    // 其他配置项（如并发数、提示词、LLM配置等）不需要重启HTTP服务
    // 这些配置会通过 EnhancedTranslationService.updateConfig 动态更新
    return false;
  }

  void clearError() {
    if (state.error != null && mounted) {
      state = state.copyWith(error: null);
    }
  }
}

// 模型管理提供者
final modelProvider =
    StateNotifierProvider.family<ModelNotifier, ModelState, String>((
      ref,
      provider,
    ) {
      final llmService = ref.watch(llmServiceProvider);
      final config = ref.read(configProvider);
      final notifier = ModelNotifier(llmService, provider);

      // 设置初始配置
      notifier.updateConfig(config);

      // 监听配置变化并自动更新模型
      ref.listen<TranslationConfig>(configProvider, (previous, next) {
        if (previous != next) {
          notifier.updateConfig(next);
        }
      });

      return notifier;
    });

class ModelState {
  final List<ModelInfo> models;
  final bool isLoading;
  final String? error;

  const ModelState({
    this.models = const [],
    this.isLoading = false,
    this.error,
  });

  ModelState copyWith({
    List<ModelInfo>? models,
    bool? isLoading,
    String? error,
  }) {
    return ModelState(
      models: models ?? this.models,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ModelNotifier extends StateNotifier<ModelState> {
  final LLMService _llmService;
  final String _provider;
  TranslationConfig? _config;

  ModelNotifier(this._llmService, this._provider) : super(const ModelState());

  void updateConfig(TranslationConfig config) {
    final previousConfig = _config;
    _config = config;

    // 检查是否需要重新加载模型
    final currentProviderConfig = config.llmProviders[_provider];
    final previousProviderConfig = previousConfig?.llmProviders[_provider];

    // 如果API密钥或基础URL发生变化，重新加载模型
    if (currentProviderConfig != null &&
        (previousProviderConfig?.apiKey != currentProviderConfig.apiKey ||
            previousProviderConfig?.baseUrl != currentProviderConfig.baseUrl)) {
      if (currentProviderConfig.apiKey.isNotEmpty) {
        // 清除缓存并重新加载
        _llmService.clearModelCache(_provider);
        loadModels();
      } else {
        // API密钥为空，清空模型列表
        if (mounted) {
          state = state.copyWith(models: [], error: 'API密钥未配置');
        }
      }
    }
  }

  Future<void> loadModels() async {
    if (state.isLoading || _config == null) return;

    final providerConfig = _config!.llmProviders[_provider];
    if (providerConfig == null || providerConfig.apiKey.isEmpty) {
      if (mounted) {
        state = state.copyWith(error: 'API密钥未配置', isLoading: false);
      }
      return;
    }

    if (mounted) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final models = await _llmService.getModels(
        provider: _provider,
        config: providerConfig,
      );

      if (mounted) {
        state = state.copyWith(models: models, isLoading: false, error: null);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void clearError() {
    if (mounted) {
      state = state.copyWith(error: null);
    }
  }

  void refreshModels() {
    _llmService.clearModelCache(_provider);
    loadModels();
  }
}
