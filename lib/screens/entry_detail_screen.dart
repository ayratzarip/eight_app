import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import 'add_edit_entry_screen.dart';
import '../main.dart';

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'ru');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              'Запись журнала',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditEntryScreen(entry: entry),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Редактировать'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Удалить', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
            icon: Icon(
              Icons.more_vert,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? CustomColors.darkGradientStart
                  : CustomColors.lightGradientStart,
              isDark
                  ? CustomColors.darkGradientEnd
                  : CustomColors.lightGradientEnd,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 90, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Дата и время
              _buildDetailCard(
                context: context,
                title: 'Дата и время записи',
                content: dateFormat.format(entry.dateTime),
                icon: Icons.access_time,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Описание ситуации',
                content: entry.situationDescription,
                icon: Icons.description,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Фокус внимания',
                content: entry.attentionFocus,
                icon: Icons.center_focus_strong,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Мысли',
                content: entry.thoughts,
                icon: Icons.psychology,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Телесные ощущения',
                content: entry.bodySensations,
                icon: Icons.accessibility_new,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Действия',
                content: entry.actions,
                icon: Icons.directions_run,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 18),
              _buildDetailCard(
                context: context,
                title: 'Что делать в будущем',
                content: entry.futureActions,
                icon: Icons.lightbulb,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(
                    context,
                  ).textTheme.titleLarge?.color?.withValues(alpha: 0.18) ??
                  Colors.blue.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditEntryScreen(entry: entry),
              ),
            );
          },
          icon: const Icon(Icons.edit, size: 24),
          label: const Text(
            'Редактировать',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        color: isDark ? CustomColors.darkCard : CustomColors.lightCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? CustomColors.darkCard : const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                content.isNotEmpty ? content : 'Не указано',
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isDark ? CustomColors.darkText : const Color(0xFF222B45),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
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
                  context.read<DiaryProvider>().deleteEntry(entry.id!);
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
