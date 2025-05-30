import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import 'add_edit_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'instructions_screen.dart';
import 'goals_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../main.dart';

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

    final csvDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<String> csvRows = [];

    csvRows.add(
      'id,dateTime,situationDescription,attentionFocus,thoughts,bodySensations,actions,futureActions',
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
      // Веб-экспорт временно недоступен
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Экспорт в веб-версии временно недоступен'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      debugPrint('---- НАЧАЛО ЭКСПОРТА CSV ----');
      debugPrint(csvData);
      debugPrint('---- КОНЕЦ ЭКСПОРТА CSV ----');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Данные CSV выведены в консоль отладки (для мобильных).',
            ),
            backgroundColor: Colors.blue,
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
                      'Журнал самооценки',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Provider.of<ThemeProvider>(context).themeMode ==
                                  ThemeMode.dark
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_round,
                          size: 24,
                          color: kLogoGreen,
                        ),
                        tooltip:
                            Provider.of<ThemeProvider>(context).themeMode ==
                                    ThemeMode.dark
                                ? 'Светлая тема'
                                : 'Тёмная тема',
                        onPressed: () {
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).toggleTheme();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.download_outlined,
                          size: 24,
                          color: kLogoGreen,
                        ),
                        tooltip: 'Экспорт в CSV',
                        onPressed: () => _exportToCsv(context),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: kLogoGreen,
                        ),
                        tooltip: 'Новая запись',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddEditEntryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                                : 'Журнал пуст',
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
                                : 'Нажмите + чтобы добавить первую запись',
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
                        child: Text(
                          provider.searchQuery.isNotEmpty
                              ? 'Найденные записи (${entries.length})'
                              : 'Записи',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
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
