import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/app_providers.dart';
import 'services/locale_service.dart';
import 'widgets/config_panel.dart';
import 'widgets/server_control_panel.dart';
import 'widgets/translation_logs.dart';
import 'widgets/language_switcher.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'XUnity AI Translator',
      theme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  List<_TabItem> get _tabs => [
    _TabItem(
      icon: Icons.tune,
      labelKey: 'configuration',
      activeIcon: Icons.tune,
    ),
    _TabItem(
      icon: Icons.power_settings_new_outlined,
      labelKey: 'serverControl',
      activeIcon: Icons.power_settings_new,
    ),
    _TabItem(
      icon: Icons.history_outlined,
      labelKey: 'translationLogs',
      activeIcon: Icons.history,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getLocalizedLabel(BuildContext context, String labelKey) {
    final l10n = AppLocalizations.of(context);
    switch (labelKey) {
      case 'configuration':
        return l10n.configuration;
      case 'serverControl':
        return l10n.serverControl;
      case 'translationLogs':
        return l10n.translationLogs;
      default:
        return labelKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [_buildSideNavigation(), _buildMainContent()]),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [_buildAppHeader(), _buildNavigationMenu(), _buildFooter()],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXXXLarge),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
            ),
            child: Icon(
              Icons.translate,
              color: AppTheme.textPrimary,
              size: AppTheme.iconSizeXLarge,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Text(
            'XUnity AI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'Translator',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
        itemCount: _tabs.length,
        itemBuilder: (context, index) => _buildNavigationItem(index),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final tab = _tabs[index];
    final isActive = index == _currentIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge,
              vertical: AppTheme.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: isActive
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: AppTheme.iconSizeMedium,
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Text(
                  _getLocalizedLabel(context, tab.labelKey),
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary.withValues(alpha: 0.8),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          const SizedBox(height: AppTheme.spacingMedium),
          const LanguageSwitcher(),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'v1.0.0',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _ContentWrapper(child: ConfigPanel()),
          _ContentWrapper(child: ServerControlPanel()),
          _ContentWrapper(isExpandable: true, child: TranslationLogs()),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

class _ContentWrapper extends StatelessWidget {
  final Widget child;
  final bool isExpandable;

  const _ContentWrapper({required this.child, this.isExpandable = false});

  @override
  Widget build(BuildContext context) {
    if (isExpandable) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXXLarge),
        child: child,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXXLarge),
      child: child,
    );
  }
}
