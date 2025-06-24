// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'XUnity AI Translator';

  @override
  String get configuration => 'Configuration';

  @override
  String get serverControl => 'Server Control';

  @override
  String get translationLogs => 'Translation Logs';

  @override
  String get configurationSubtitle =>
      'Configure AI models and translation parameters';

  @override
  String get serverControlSubtitle =>
      'Start and manage HTTP translation service';

  @override
  String get translationLogsSubtitle =>
      'View detailed records of all translation requests';

  @override
  String get llmConfiguration => 'LLM Configuration';

  @override
  String get provider => 'Provider';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get model => 'Model';

  @override
  String get temperature => 'Temperature';

  @override
  String get maxTokens => 'Max Tokens';

  @override
  String get topP => 'Top P';

  @override
  String get frequencyPenalty => 'Frequency Penalty';

  @override
  String get presencePenalty => 'Presence Penalty';

  @override
  String get translationConfiguration => 'Translation Configuration';

  @override
  String get promptTemplate => 'Prompt Template';

  @override
  String get outputRegex => 'Output Regex';

  @override
  String get serverConfiguration => 'Server Configuration';

  @override
  String get httpServerPort => 'HTTP Server Port';

  @override
  String get concurrencyCount => 'Concurrency Count';

  @override
  String get serverStatus => 'Server Status';

  @override
  String get serverRunning => 'Server Running';

  @override
  String get serverStopped => 'Server Stopped';

  @override
  String port(int port) {
    return 'Port: $port';
  }

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get startServer => 'Start Server';

  @override
  String get stopServer => 'Stop Server';

  @override
  String get apiEndpoints => 'API Endpoints';

  @override
  String get translateEndpoint => 'Translation Endpoint';

  @override
  String get healthCheckEndpoint => 'Health Check Endpoint';

  @override
  String get noTranslationRecords => 'No Translation Records';

  @override
  String get noTranslationRecordsSubtitle =>
      'After starting the server and performing translations, records will be displayed here';

  @override
  String get recentTranslationRecords => 'Recent Translation Records';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String recordsCount(int count) {
    return '$count records';
  }

  @override
  String duration(int duration) {
    return '${duration}ms';
  }

  @override
  String get originalText => 'Original Text';

  @override
  String get translatedText => 'Translated Text';

  @override
  String get requestDetails => 'Request Details';

  @override
  String get responseDetails => 'Response Details';

  @override
  String get noResponse => 'No response content';

  @override
  String get modelLoading => 'Model Loading';

  @override
  String get modelReady => 'Model Ready';

  @override
  String get modelError => 'Model Error';

  @override
  String get loading => 'Loading...';

  @override
  String get ready => 'Ready';

  @override
  String get modelStatus => 'Model Status';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get advancedConfiguration => 'Advanced Configuration';
}
