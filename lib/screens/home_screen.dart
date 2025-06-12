import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'instructions_screen.dart';
import 'goals_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 - Журнал, 1 - Цели, 2 - Инструкции

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _selectedTab) return;
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoalsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InstructionsScreen()),
      );
    }
    setState(() {
      _selectedTab = index;
    });
  }

  String _sanitizeCsvField(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

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

  Future<void> _exportToCsv(BuildContext context) async {
    final provider = context.read<DiaryProvider>();
    if (provider.isLoading) {
      await provider.loadEntries();
    }
    final entries = provider.allEntries;

    if (entries.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет записей для экспорта.')),
        );
      }
      return;
    }

    // Показываем индикатор загрузки
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Подготовка файла...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final csvDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final fileNameDateFormat = DateFormat('yyyy-MM-dd_HH-mm');

      List<String> csvRows = [];

      // Заголовки с понятными названиями на русском
      csvRows.add(
        'ID,Дата и время,Описание ситуации,Фокус внимания,Мысли,Телесные ощущения,Действия,Планы на будущее',
      );

      for (var entry in entries) {
        List<String> row = [
          _sanitizeCsvField((entry.id ?? 0).toString()),
          _sanitizeCsvField(csvDateFormat.format(entry.dateTime)),
          _sanitizeCsvField(entry.situationDescription),
          _sanitizeCsvField(entry.attentionFocus),
          _sanitizeCsvField(entry.thoughts),
          _sanitizeCsvField(entry.bodySensations),
          _sanitizeCsvField(_cleanActionsText(entry.actions)),
          _sanitizeCsvField(_cleanFutureActionsText(entry.futureActions)),
        ];
        csvRows.add(row.join(','));
      }

      String csvData = csvRows.join('\n');

      if (kIsWeb) {
        // Для веб-версии используем share_plus
        await Share.share(csvData, subject: 'Экспорт журнала самонаблюдения');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Данные CSV готовы к сохранению'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Для мобильных платформ создаем файл
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'journal_export_${fileNameDateFormat.format(DateTime.now())}.csv';
        final file = File('${directory.path}/$fileName');

        await file.writeAsString(csvData, encoding: utf8);

        // Делимся файлом через системное меню
        final result = await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Экспорт журнала самонаблюдения',
          text:
              'Экспорт данных из приложения "Журнал самонаблюдения" за ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
        );

        if (context.mounted) {
          if (result.status == ShareResultStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Файл $fileName успешно экспортирован'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Повторить',
                  onPressed: () => _exportToCsv(context),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Файл $fileName создан и готов к отправке'),
                backgroundColor: Colors.blue,
                action: SnackBarAction(
                  label: 'Повторить',
                  onPressed: () => _exportToCsv(context),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _exportToCsv(context),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Цвет Tailwind text-green-700
    const Color kLogoGreen = Color(0xFF2f855a);

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
                  Expanded(
                    child: Text(
                      'Журнал',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: kLogoGreen),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddEditEntryScreen(),
                            ),
                          );
                        },
                        tooltip: 'Новая запись',
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_download_outlined),
                        onPressed: () => _exportToCsv(context),
                        tooltip: 'Экспорт в CSV',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Блок аналитики
            Consumer<DiaryProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242731) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _AnalyticItem(
                          icon: Icons.book_outlined,
                          label: 'Всего записей',
                          value: provider.totalEntries.toString(),
                          isDark: isDark,
                          useHeaderColor: true,
                          isActive: provider.currentFilter == EntryFilter.all,
                          onTap: () => provider.setFilter(EntryFilter.all),
                        ),
                      ),
                      Expanded(
                        child: _AnalyticItem(
                          icon: Icons.check_circle_outline,
                          label: 'Был эффективен',
                          value:
                              '${provider.effectiveEntriesPercentage.toStringAsFixed(1)}%',
                          color: kLogoGreen,
                          isDark: isDark,
                          isActive:
                              provider.currentFilter == EntryFilter.effective,
                          onTap:
                              () => provider.setFilter(EntryFilter.effective),
                        ),
                      ),
                      Expanded(
                        child: _AnalyticItem(
                          icon: Icons.help_outline,
                          label: 'Нужен совет',
                          value: provider.needHelpEntries.toString(),
                          color: Colors.orange,
                          isDark: isDark,
                          isActive:
                              provider.currentFilter == EntryFilter.needHelp,
                          onTap: () => provider.setFilter(EntryFilter.needHelp),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Строка поиска
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск записей',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Consumer<DiaryProvider>(
                    builder: (context, provider, child) {
                      return provider.searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                          : const SizedBox.shrink();
                    },
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  context.read<DiaryProvider>().setSearchQuery(value);
                },
              ),
            ),
            // Список записей
            Expanded(
              child: Consumer<DiaryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = provider.filteredEntries;
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: isDark ? Colors.white38 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'Записи не найдены'
                                : provider.currentFilter == EntryFilter.all
                                ? 'Журнал пуст'
                                : provider.currentFilter ==
                                    EntryFilter.effective
                                ? 'Нет эффективных записей'
                                : 'Нет записей, требующих совета',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'Попробуйте изменить поисковый запрос'
                                : provider.currentFilter == EntryFilter.all
                                ? 'Нажмите + чтобы добавить первую запись'
                                : 'Попробуйте выбрать другой фильтр',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    children: [
                      // Заголовок записей
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.searchQuery.isNotEmpty
                                    ? 'Найденные записи (${entries.length})'
                                    : provider.currentFilter ==
                                        EntryFilter.effective
                                    ? 'Эффективные записи (${entries.length})'
                                    : provider.currentFilter ==
                                        EntryFilter.needHelp
                                    ? 'Записи, требующие совета (${entries.length})'
                                    : 'Записи',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            if (provider.currentFilter != EntryFilter.all)
                              TextButton.icon(
                                onPressed:
                                    () => provider.setFilter(EntryFilter.all),
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Сбросить'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Контейнер с записями
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF23242B) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entries.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 1,
                                color:
                                    isDark ? Colors.white12 : Colors.grey[200],
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return _buildEntryCard(context, entry);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _onTabTapped,
        selectedItemColor: kLogoGreen,
        unselectedItemColor: theme.iconTheme.color?.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.stairs), label: 'Цели'),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Инструкции',
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, DiaryEntry entry) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntryDetailScreen(entry: entry),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Дата
            Text(
              dateFormat.format(entry.dateTime),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            // Текст ситуации
            Expanded(
              child: Text(
                entry.situationDescription.isNotEmpty
                    ? entry.situationDescription
                    : 'Нет описания',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Меню действий
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
                  _showDeleteDialog(context, entry);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
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
              icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Удалить запись?'),
          content: const Text(
            'Вы уверены, что хотите удалить эту запись? Это действие необратимо.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
              onPressed: () {
                context.read<DiaryProvider>().deleteEntry(entry.id!);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Запись удалена'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? color;
  final bool useHeaderColor;
  final bool isActive;
  final VoidCallback onTap;

  const _AnalyticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.color,
    this.useHeaderColor = false,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Color valueColor;

    if (useHeaderColor) {
      // Используем цвет заголовков
      iconColor = isDark ? Colors.white : Colors.black;
      valueColor = isDark ? Colors.white : Colors.black;
    } else {
      // Используем переданный цвет или дефолтный зеленый
      final activeColor = color ?? const Color(0xFF2f855a); // kLogoGreen
      iconColor = activeColor;
      valueColor = activeColor;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration:
            isActive
                ? BoxDecoration(
                  color:
                      (useHeaderColor
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05))
                          : (color ?? const Color(0xFF2f855a)).withValues(
                            alpha: 0.1,
                          )),
                  borderRadius: BorderRadius.circular(8),
                )
                : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
