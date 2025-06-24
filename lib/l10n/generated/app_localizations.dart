import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'XUnity AI Translator'**
  String get appTitle;

  /// Configuration tab label
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// Server control tab label
  ///
  /// In en, this message translates to:
  /// **'Server Control'**
  String get serverControl;

  /// Translation logs tab label
  ///
  /// In en, this message translates to:
  /// **'Translation Logs'**
  String get translationLogs;

  /// Configuration page subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure AI models and translation parameters'**
  String get configurationSubtitle;

  /// Server control page subtitle
  ///
  /// In en, this message translates to:
  /// **'Start and manage HTTP translation service'**
  String get serverControlSubtitle;

  /// Translation logs page subtitle
  ///
  /// In en, this message translates to:
  /// **'View detailed records of all translation requests'**
  String get translationLogsSubtitle;

  /// LLM configuration section title
  ///
  /// In en, this message translates to:
  /// **'LLM Configuration'**
  String get llmConfiguration;

  /// Provider field label
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// Base URL field label
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// API Key field label
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// Model field label
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Temperature field label
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Max tokens field label
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get maxTokens;

  /// Top P field label
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topP;

  /// Frequency penalty field label
  ///
  /// In en, this message translates to:
  /// **'Frequency Penalty'**
  String get frequencyPenalty;

  /// Presence penalty field label
  ///
  /// In en, this message translates to:
  /// **'Presence Penalty'**
  String get presencePenalty;

  /// Translation configuration section title
  ///
  /// In en, this message translates to:
  /// **'Translation Configuration'**
  String get translationConfiguration;

  /// Prompt template field label
  ///
  /// In en, this message translates to:
  /// **'Prompt Template'**
  String get promptTemplate;

  /// Output regex field label
  ///
  /// In en, this message translates to:
  /// **'Output Regex'**
  String get outputRegex;

  /// Server configuration section title
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get serverConfiguration;

  /// HTTP server port field label
  ///
  /// In en, this message translates to:
  /// **'HTTP Server Port'**
  String get httpServerPort;

  /// Concurrency count field label
  ///
  /// In en, this message translates to:
  /// **'Concurrency Count'**
  String get concurrencyCount;

  /// Server status section title
  ///
  /// In en, this message translates to:
  /// **'Server Status'**
  String get serverStatus;

  /// Server running status
  ///
  /// In en, this message translates to:
  /// **'Server Running'**
  String get serverRunning;

  /// Server stopped status
  ///
  /// In en, this message translates to:
  /// **'Server Stopped'**
  String get serverStopped;

  /// Port display
  ///
  /// In en, this message translates to:
  /// **'Port: {port}'**
  String port(int port);

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// Start server button
  ///
  /// In en, this message translates to:
  /// **'Start Server'**
  String get startServer;

  /// Stop server button
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get stopServer;

  /// API endpoints section title
  ///
  /// In en, this message translates to:
  /// **'API Endpoints'**
  String get apiEndpoints;

  /// Translation endpoint label
  ///
  /// In en, this message translates to:
  /// **'Translation Endpoint'**
  String get translateEndpoint;

  /// Health check endpoint label
  ///
  /// In en, this message translates to:
  /// **'Health Check Endpoint'**
  String get healthCheckEndpoint;

  /// Empty state title for translation logs
  ///
  /// In en, this message translates to:
  /// **'No Translation Records'**
  String get noTranslationRecords;

  /// Empty state subtitle for translation logs
  ///
  /// In en, this message translates to:
  /// **'After starting the server and performing translations, records will be displayed here'**
  String get noTranslationRecordsSubtitle;

  /// Recent translation records section title
  ///
  /// In en, this message translates to:
  /// **'Recent Translation Records'**
  String get recentTranslationRecords;

  /// Clear logs button
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// Records count display
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String recordsCount(int count);

  /// Duration display
  ///
  /// In en, this message translates to:
  /// **'{duration}ms'**
  String duration(int duration);

  /// Original text label
  ///
  /// In en, this message translates to:
  /// **'Original Text'**
  String get originalText;

  /// Translated text label
  ///
  /// In en, this message translates to:
  /// **'Translated Text'**
  String get translatedText;

  /// Request details section title
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// Response details section title
  ///
  /// In en, this message translates to:
  /// **'Response Details'**
  String get responseDetails;

  /// No response message
  ///
  /// In en, this message translates to:
  /// **'No response content'**
  String get noResponse;

  /// Model loading status
  ///
  /// In en, this message translates to:
  /// **'Model Loading'**
  String get modelLoading;

  /// Model ready status
  ///
  /// In en, this message translates to:
  /// **'Model Ready'**
  String get modelReady;

  /// Model error status
  ///
  /// In en, this message translates to:
  /// **'Model Error'**
  String get modelError;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Ready status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Model status section title
  ///
  /// In en, this message translates to:
  /// **'Model Status'**
  String get modelStatus;

  /// Test connection button
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// Advanced configuration section title
  ///
  /// In en, this message translates to:
  /// **'Advanced Configuration'**
  String get advancedConfiguration;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
