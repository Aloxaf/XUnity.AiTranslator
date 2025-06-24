// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'XUnity AI 翻译器';

  @override
  String get configuration => '配置';

  @override
  String get serverControl => '服务控制';

  @override
  String get translationLogs => '翻译日志';

  @override
  String get configurationSubtitle => '配置 AI 模型和翻译参数';

  @override
  String get serverControlSubtitle => '启动和管理 HTTP 翻译服务';

  @override
  String get translationLogsSubtitle => '查看所有翻译请求的详细记录';

  @override
  String get llmConfiguration => 'LLM 配置';

  @override
  String get provider => '服务提供商';

  @override
  String get baseUrl => '基础 URL';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get model => '模型';

  @override
  String get temperature => '温度';

  @override
  String get maxTokens => '最大令牌数';

  @override
  String get topP => 'Top P';

  @override
  String get frequencyPenalty => '频率惩罚';

  @override
  String get presencePenalty => '存在惩罚';

  @override
  String get translationConfiguration => '翻译配置';

  @override
  String get promptTemplate => '提示词模板';

  @override
  String get outputRegex => '输出正则表达式';

  @override
  String get serverConfiguration => '服务器配置';

  @override
  String get httpServerPort => 'HTTP 服务端口';

  @override
  String get concurrencyCount => '并发数量';

  @override
  String get serverStatus => '服务器状态';

  @override
  String get serverRunning => '服务器运行中';

  @override
  String get serverStopped => '服务器已停止';

  @override
  String port(int port) {
    return '端口: $port';
  }

  @override
  String error(String error) {
    return '错误: $error';
  }

  @override
  String get startServer => '启动服务器';

  @override
  String get stopServer => '停止服务器';

  @override
  String get apiEndpoints => 'API 端点';

  @override
  String get translateEndpoint => '翻译端点';

  @override
  String get healthCheckEndpoint => '健康检查端点';

  @override
  String get noTranslationRecords => '暂无翻译记录';

  @override
  String get noTranslationRecordsSubtitle => '启动服务器并进行翻译后，记录将在这里显示';

  @override
  String get recentTranslationRecords => '最近的翻译记录';

  @override
  String get clearLogs => '清空日志';

  @override
  String recordsCount(int count) {
    return '$count 条记录';
  }

  @override
  String duration(int duration) {
    return '$duration毫秒';
  }

  @override
  String get originalText => '原文';

  @override
  String get translatedText => '译文';

  @override
  String get requestDetails => '请求详情';

  @override
  String get responseDetails => '响应详情';

  @override
  String get noResponse => '无响应内容';

  @override
  String get modelLoading => '模型加载中';

  @override
  String get modelReady => '模型就绪';

  @override
  String get modelError => '模型错误';

  @override
  String get loading => '加载中...';

  @override
  String get ready => '就绪';

  @override
  String get modelStatus => '模型状态';

  @override
  String get testConnection => '测试连接';

  @override
  String get advancedConfiguration => '高级配置';

  @override
  String get templateHint => '提示词模板支持变量：{from} 源语言，{to} 目标语言，{text} 待翻译文本';

  @override
  String get advancedConfigurationHint =>
      'Temperature 控制输出随机性，Top P 控制采样多样性，Penalty 参数用于减少重复和鼓励新内容';
}
