import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';

class ConfigPanel extends ConsumerStatefulWidget {
  const ConfigPanel({super.key});

  @override
  ConsumerState<ConfigPanel> createState() => _ConfigPanelState();
}

class _ConfigPanelState extends ConsumerState<ConfigPanel> {
  late TextEditingController _portController;
  late TextEditingController _promptController;
  late TextEditingController _regexController;
  late TextEditingController _concurrencyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;

  String _selectedProvider = 'OpenRouter';

  final List<String> _providers = [
    'OpenRouter',
    'OpenAI',
    'Azure OpenAI',
    '自定义',
  ];

  final Map<String, Map<String, String>> _providerDefaults = {
    'OpenRouter': {
      'baseUrl': 'https://openrouter.ai/api/v1',
      'model': 'anthropic/claude-3.5-sonnet',
    },
    'OpenAI': {'baseUrl': 'https://api.openai.com/v1', 'model': 'gpt-4'},
    'Azure OpenAI': {
      'baseUrl': 'https://your-resource.openai.azure.com',
      'model': 'gpt-4',
    },
    '自定义': {'baseUrl': '', 'model': ''},
  };

  @override
  void initState() {
    super.initState();
    // 使用默认配置初始化控制器
    _initControllers(const TranslationConfig());

    // 延迟加载实际配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(configProvider);
      _updateControllers(config);
    });
  }

  void _initControllers(TranslationConfig config) {
    _portController = TextEditingController(text: config.serverPort.toString());
    _promptController = TextEditingController(text: config.promptTemplate);
    _regexController = TextEditingController(text: config.outputRegex);
    _concurrencyController = TextEditingController(
      text: config.concurrency.toString(),
    );
    _baseUrlController = TextEditingController(text: config.llmService.baseUrl);
    _apiKeyController = TextEditingController(text: config.llmService.apiKey);
    _modelController = TextEditingController(text: config.llmService.model);
    _selectedProvider = config.llmService.provider;
  }

  void _updateControllers(TranslationConfig config) {
    if (mounted) {
      setState(() {
        _portController.text = config.serverPort.toString();
        _promptController.text = config.promptTemplate;
        _regexController.text = config.outputRegex;
        _concurrencyController.text = config.concurrency.toString();
        _baseUrlController.text = config.llmService.baseUrl;
        _apiKeyController.text = config.llmService.apiKey;
        _modelController.text = config.llmService.model;
        _selectedProvider = config.llmService.provider;
      });
    }
  }

  @override
  void dispose() {
    _portController.dispose();
    _promptController.dispose();
    _regexController.dispose();
    _concurrencyController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onProviderChanged(String? provider) {
    if (provider != null) {
      setState(() {
        _selectedProvider = provider;
        final defaults = _providerDefaults[provider]!;
        _baseUrlController.text = defaults['baseUrl']!;
        _modelController.text = defaults['model']!;
      });
    }
  }

  void _saveConfig() {
    try {
      final config = TranslationConfig(
        serverPort: int.parse(_portController.text),
        promptTemplate: _promptController.text,
        outputRegex: _regexController.text,
        concurrency: int.parse(_concurrencyController.text),
        llmService: LLMServiceConfig(
          provider: _selectedProvider,
          baseUrl: _baseUrlController.text,
          apiKey: _apiKeyController.text,
          model: _modelController.text,
        ),
      );

      ref.read(configProvider.notifier).updateConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('配置已保存'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('保存配置失败: $e'),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听配置变化并更新控制器
    ref.listen<TranslationConfig>(configProvider, (previous, next) {
      if (previous != next) {
        _updateControllers(next);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '应用配置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '配置翻译服务的各项参数',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 32),

        // 服务配置卡片
        _buildConfigCard(
          title: '服务配置',
          icon: Icons.settings,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _portController,
                    label: 'HTTP 服务端口',
                    hint: '8080',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _concurrencyController,
                    label: '并发数量',
                    hint: '3',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // LLM 服务配置卡片
        _buildConfigCard(
          title: 'LLM 服务配置',
          icon: Icons.psychology,
          children: [
            _buildDropdownField(
              label: 'LLM 服务提供商',
              value: _selectedProvider,
              items: _providers,
              onChanged: _onProviderChanged,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _baseUrlController,
              label: 'API 基础 URL',
              hint: 'https://openrouter.ai/api/v1',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _apiKeyController,
                    label: 'API 密钥',
                    hint: '输入您的 API 密钥',
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _modelController,
                    label: '模型',
                    hint: 'gpt-4',
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 提示词配置卡片
        _buildConfigCard(
          title: '提示词配置',
          icon: Icons.edit_note,
          children: [
            _buildTextField(
              controller: _promptController,
              label: '提示词模板',
              hint: '支持 {from}, {to}, {text} 变量',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _regexController,
              label: '输出提取正则表达式',
              hint: r'Translation:\s*(.+)',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF1E40AF).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF3B82F6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '提示词模板支持变量：{from} 源语言，{to} 目标语言，{text} 待翻译文本',
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // 保存按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveConfig,
            icon: const Icon(Icons.save),
            label: const Text('保存配置'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
