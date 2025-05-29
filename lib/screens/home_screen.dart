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

  String _sanitizeCsvField(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
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
        _sanitizeCsvField(entry.actions),
        _sanitizeCsvField(entry.futureActions),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 10),
            Text(
              'Soft Skills Engine: Logbook',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
            ),
            tooltip:
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                    ? 'Светлая тема'
                    : 'Тёмная тема',
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
            ),
            tooltip: 'Инструкции',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InstructionsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.download_outlined,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
            ),
            tooltip: 'Экспорт в CSV',
            onPressed: () {
              _exportToCsv(context);
            },
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
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark ? CustomColors.darkCard : CustomColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color:
                          isDark
                              ? CustomColors.darkText
                              : CustomColors.lightText,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Поиск записей...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: Consumer<DiaryProvider>(
                        builder: (context, provider, child) {
                          return provider.searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xFF3A5BA0),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearSearch();
                                },
                              )
                              : const SizedBox.shrink();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<DiaryProvider>().setSearchQuery(value);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<DiaryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = provider.filteredEntries;
                  if (entries.isEmpty) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.18),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Журнал пуст',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color ??
                                    Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Почитайте инструкцию, чтобы узнать, как вести журнал, а затем нажмите «Новая запись», чтобы добавить первую заметку.',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF222B45),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            Center(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3A5BA0),
                                      Color(0xFF6EC6F5),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color
                                              ?.withValues(alpha: 0.18) ??
                                          Colors.blue.withValues(alpha: 0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const InstructionsScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.help_outline,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    'Инструкция',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildEntryCard(context, entry, colorScheme);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 18, right: 0, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).textTheme.titleLarge?.color
                              ?.withValues(alpha: 0.18) ??
                          Colors.blue.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined, size: 22),
                  label: const Text(
                    'Цели',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 44,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).textTheme.titleLarge?.color
                              ?.withValues(alpha: 0.18) ??
                          Colors.blue.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditEntryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Новая запись',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(
    BuildContext context,
    DiaryEntry entry,
    ColorScheme colorScheme,
  ) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(
                  context,
                ).textTheme.titleLarge?.color?.withValues(alpha: 0.08) ??
                Colors.blue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        gradient:
            isDark
                ? null
                : const LinearGradient(
                  colors: [Color(0xFFF6F8FB), Color(0xFFEAF1FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        color: isDark ? Colors.black : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntryDetailScreen(entry: entry),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 8,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.blue,
                          Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.blue,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color
                                      ?.withValues(alpha: 0.7) ??
                                  Colors.blue.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(entry.dateTime),
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color
                                        ?.withValues(alpha: 0.7) ??
                                    Colors.blue.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AddEditEntryScreen(entry: entry),
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
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Удалить',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                              icon: Icon(
                                Icons.more_vert,
                                color:
                                    Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color
                                        ?.withValues(alpha: 0.7) ??
                                    Colors.blue.withValues(alpha: 0.7),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ситуация',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.situationDescription.isNotEmpty
                              ? entry.situationDescription
                              : 'Не указано',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
