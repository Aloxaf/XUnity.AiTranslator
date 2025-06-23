import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class ServerControlPanel extends ConsumerWidget {
  const ServerControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverState = ref.watch(serverStateProvider);
    final config = ref.watch(configProvider);

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
              child: const Icon(
                Icons.power_settings_new,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '服务控制',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '启动和管理 HTTP 翻译服务',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 32),

        // 服务器状态卡片
        Container(
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
                  Icon(Icons.dns, color: const Color(0xFF6366F1), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '服务器状态',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 状态指示器
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: serverState.isRunning
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF6B7280).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: serverState.isRunning
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFF6B7280).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: serverState.isRunning
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serverState.isRunning ? '服务器运行中' : '服务器已停止',
                            style: TextStyle(
                              color: serverState.isRunning
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (serverState.isRunning) ...[
                            const SizedBox(height: 4),
                            Text(
                              '端口: ${serverState.port}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (serverState.isRunning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '在线',
                          style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 错误信息
              if (serverState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: const Color(0xFFEF4444),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '错误: ${serverState.error}',
                          style: TextStyle(
                            color: const Color(0xFFEF4444),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 控制按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: serverState.isRunning
                          ? null
                          : () => ref
                                .read(serverStateProvider.notifier)
                                .startServer(config.serverPort),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('启动服务器'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade800,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: serverState.isRunning
                          ? () => ref
                                .read(serverStateProvider.notifier)
                                .stopServer()
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('停止服务器'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors.grey.shade800,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // API 端点信息
        if (serverState.isRunning) ...[
          const SizedBox(height: 24),
          Container(
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
                    Icon(Icons.api, color: const Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'API 端点信息',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildApiEndpoint(
                  context: context,
                  title: '翻译端点',
                  description: '用于翻译文本的主要 API 端点',
                  url:
                      'curl http://localhost:${serverState.port}/translate?from=en&to=zh&text=Hello',
                  icon: Icons.translate,
                ),

                const SizedBox(height: 16),

                _buildApiEndpoint(
                  context: context,
                  title: '健康检查',
                  description: '检查服务器运行状态',
                  url: 'curl http://localhost:${serverState.port}/health',
                  icon: Icons.health_and_safety,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApiEndpoint({
    required BuildContext context,
    required String title,
    required String description,
    required String url,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: const Color(0xFF3B82F6), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('已复制到剪贴板'),
                          backgroundColor: const Color(0xFF10B981),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  tooltip: '复制',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
