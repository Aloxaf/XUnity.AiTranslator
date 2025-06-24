import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/config_panel.dart';
import 'widgets/server_control_panel.dart';
import 'widgets/translation_logs.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XUnity AI Translator',
      theme: AppTheme.darkTheme,
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

  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.tune, label: '配置', activeIcon: Icons.tune),
    _TabItem(
      icon: Icons.power_settings_new_outlined,
      label: '服务控制',
      activeIcon: Icons.power_settings_new,
    ),
    _TabItem(
      icon: Icons.history_outlined,
      label: '翻译日志',
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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.translate, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'XUnity AI',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Translator',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) => _buildNavigationItem(index),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final tab = _tabs[index];
    final isActive = index == _currentIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  tab.label,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : Colors.white.withValues(alpha: 0.8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          const SizedBox(height: 8),
          Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
            ),
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
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _ContentWrapper extends StatelessWidget {
  final Widget child;
  final bool isExpandable;

  const _ContentWrapper({required this.child, this.isExpandable = false});

  @override
  Widget build(BuildContext context) {
    if (isExpandable) {
      return Padding(padding: const EdgeInsets.all(32), child: child);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: child,
    );
  }
}
