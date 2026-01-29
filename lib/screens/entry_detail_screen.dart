import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../styles/app_styles.dart';
import 'add_edit_entry_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  // Функция для очистки разделителей из текста действий
  String _cleanActionsText(String actions) {
    const actionResultSeparator = "||RESULT:";
    final separatorIndex = actions.indexOf(actionResultSeparator);
    if (separatorIndex != -1) {
      return actions.substring(0, separatorIndex);
    }
    return actions;
  }

  // Функция для очистки разделителей из текста будущих действий
  String _cleanFutureActionsText(String futureActions) {
    const futureActionOptionSeparator = "||FA_OPTION:";
    final separatorIndex = futureActions.indexOf(futureActionOptionSeparator);
    if (separatorIndex != -1) {
      final option = futureActions.substring(0, separatorIndex);
      final text = futureActions.substring(
        separatorIndex + futureActionOptionSeparator.length,
      );
      if (text.trim().isEmpty) {
        return option;
      } else {
        return '$option. $text';
      }
    }
    return futureActions;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'ru');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Крупный заголовок и кнопки действий
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка возврата
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: AppColors.logoGreen,
                    ),
                    tooltip: 'Назад',
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Заголовок
                  Expanded(
                    child: Text(
                      'Запись журнала',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Кнопки действий
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'Редактировать',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddEditEntryScreen(entry: entry),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        tooltip: 'Удалить',
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Дата записи
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                dateFormat.format(entry.dateTime),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Контент записи
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                children: [
                  // Контейнер с данными записи
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23242B) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailItem(
                          context: context,
                          title: 'Описание ситуации',
                          content: entry.situationDescription,
                          icon: Icons.description,
                          isFirst: true,
                        ),
                        _buildDivider(isDark),
                        _buildDetailItem(
                          context: context,
                          title: 'Фокус внимания',
                          content: entry.attentionFocus,
                          icon: Icons.center_focus_strong,
                        ),
                        _buildDivider(isDark),
                        _buildDetailItem(
                          context: context,
                          title: 'Мысли',
                          content: entry.thoughts,
                          icon: Icons.psychology,
                        ),
                        _buildDivider(isDark),
                        _buildDetailItem(
                          context: context,
                          title: 'Телесные ощущения',
                          content: entry.bodySensations,
                          icon: Icons.accessibility_new,
                        ),
                        _buildDivider(isDark),
                        _buildDetailItem(
                          context: context,
                          title: 'Действия',
                          content: _cleanActionsText(entry.actions),
                          icon: Icons.directions_run,
                        ),
                        if (entry.futureActions.isNotEmpty) ...[
                          _buildDivider(isDark),
                          _buildDetailItem(
                            context: context,
                            title: 'Что делать в будущем',
                            content: _cleanFutureActionsText(
                              entry.futureActions,
                            ),
                            icon: Icons.lightbulb,
                            isLast: true,
                          ),
                        ] else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white12 : Colors.grey[200],
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 16 : 12, 16, isLast ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.logoGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : 'Не указано',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить запись?'),
            content: const Text('Это действие нельзя отменить.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  context.read<DiaryProvider>().deleteEntry(entry.id);
                  Navigator.pop(context); // Закрыть диалог
                  Navigator.pop(context); // Вернуться на главный экран
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Запись удалена'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }
}
