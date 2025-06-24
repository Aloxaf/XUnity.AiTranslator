import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class TranslationLogs extends ConsumerWidget {
  const TranslationLogs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(translationLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        PageHeader(
          title: '翻译日志',
          subtitle: '查看所有翻译请求的详细记录',
          icon: Icons.history,
          actions: [if (logs.isNotEmpty) AppBadge(label: '${logs.length} 条记录')],
        ),
        if (logs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingMedium),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ref.read(translationLogsProvider.notifier).clearLogs();
                  },
                  icon: const Icon(
                    Icons.clear_all,
                    size: AppTheme.iconSizeSmall,
                  ),
                  label: const Text('清空日志'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppTheme.spacingXXXLarge),

        // 日志列表
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: logs.isEmpty
                ? EmptyState(
                    title: '暂无翻译记录',
                    subtitle: '启动服务器并进行翻译后，记录将在这里显示',
                    icon: Icons.history_outlined,
                  )
                : Column(
                    children: [
                      // 列表头部
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppTheme.dividerColor),
                          ),
                        ),
                        child: CardHeader(
                          title: '最近的翻译记录',
                          icon: Icons.list_alt,
                        ),
                      ),
                      // 日志项列表
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppTheme.spacingMedium,
                              ),
                              child: TranslationLogItem(log: log),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class TranslationLogItem extends StatefulWidget {
  final TranslationLog log;

  const TranslationLogItem({super.key, required this.log});

  @override
  State<TranslationLogItem> createState() => _TranslationLogItemState();
}

class _TranslationLogItemState extends State<TranslationLogItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.log.isSuccess
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Container(
      decoration: AppTheme.contentDecoration(
        borderColor: statusColor.withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          // 折叠头部
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Row(
                  children: [
                    // 状态指示器
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),

                    // 语言方向
                    AppChip.primary(
                      label: '${widget.log.from} → ${widget.log.to}',
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),

                    // 原文预览
                    Expanded(
                      child: Text(
                        widget.log.originalText,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),

                    // 时长标签
                    AppChip.neutral(
                      label: '${widget.log.duration.inMilliseconds}ms',
                      fontSize: 10,
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),

                    // 时间
                    Text(
                      _formatTime(widget.log.timestamp),
                      style: TextStyle(
                        color: AppTheme.textDisabled,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),

                    // 展开图标
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.textDisabled,
                        size: AppTheme.iconSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 展开内容
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLarge,
                0,
                AppTheme.spacingLarge,
                AppTheme.spacingLarge,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingLarge),

                  // 原文
                  _buildContentSection(
                    title: '原文',
                    content: widget.log.originalText,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // 译文或错误
                  if (widget.log.isSuccess)
                    _buildContentSection(
                      title: '译文',
                      content: widget.log.translatedText,
                      color: AppTheme.successColor,
                    )
                  else if (widget.log.error != null)
                    _buildContentSection(
                      title: '错误信息',
                      content: widget.log.error!,
                      color: AppTheme.errorColor,
                    ),

                  const SizedBox(height: AppTheme.spacingLarge),

                  // 详细信息
                  Wrap(
                    spacing: AppTheme.spacingMedium,
                    children: [
                      _buildInfoChip('ID', widget.log.id.substring(0, 8)),
                      _buildInfoChip(
                        '时长',
                        '${widget.log.duration.inMilliseconds}ms',
                      ),
                      _buildInfoChip(
                        '状态',
                        widget.log.isSuccess ? '成功' : '失败',
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return AppChip(
      label: '$label: $value',
      color: color ?? AppTheme.textDisabled,
      fontSize: 10,
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
