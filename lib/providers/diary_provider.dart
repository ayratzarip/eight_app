import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';

enum EntryFilter { all, effective, needHelp }

class DiaryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  String _searchQuery = '';
  EntryFilter _currentFilter = EntryFilter.all;

  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get allEntries => _entries;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  EntryFilter get currentFilter => _currentFilter;

  List<DiaryEntry> get filteredEntries {
    List<DiaryEntry> entries = _entries;

    // Применяем фильтр аналитики
    switch (_currentFilter) {
      case EntryFilter.effective:
        entries =
            entries
                .where((entry) => entry.futureActions.trim().isEmpty)
                .toList();
        break;
      case EntryFilter.needHelp:
        entries =
            entries.where((entry) {
              final futureActionParts = entry.futureActions.split(
                '||FA_OPTION:',
              );
              return futureActionParts.length > 1 &&
                  futureActionParts[0].trim().toLowerCase() ==
                      'не знаю, что делать в подобных ситуациях';
            }).toList();
        break;
      case EntryFilter.all:
        // Показываем все записи
        break;
    }

    // Применяем поисковый фильтр
    if (_searchQuery.isEmpty) {
      return entries;
    }
    return entries.where((entry) {
      return entry.situationDescription.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          entry.attentionFocus.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          entry.thoughts.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.bodySensations.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          entry.actions.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.futureActions.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _databaseService.getAllEntries();
    } catch (e) {
      debugPrint('Ошибка загрузки записей: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(DiaryEntry entry) async {
    try {
      await _databaseService.insertEntry(entry);
      await loadEntries();
    } catch (e) {
      debugPrint('Ошибка добавления записи: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      await _databaseService.updateEntry(entry);
      await loadEntries();
    } catch (e) {
      debugPrint('Ошибка обновления записи: $e');
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      await _databaseService.deleteEntry(id);
      await loadEntries();
    } catch (e) {
      debugPrint('Ошибка удаления записи: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setFilter(EntryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _currentFilter = EntryFilter.all;
    notifyListeners();
  }

  // Получить общее количество записей
  int get totalEntries => _entries.length;

  // Получить количество эффективных записей (где пустые будущие действия)
  int get effectiveEntries {
    return _entries.where((entry) {
      // Эффективными считаются записи, где вообще нет будущих действий
      // (когда выбрано "Добились желаемого результата")
      return entry.futureActions.trim().isEmpty;
    }).length;
  }

  // Получить процент эффективных записей
  double get effectiveEntriesPercentage {
    if (_entries.isEmpty) return 0;
    return (effectiveEntries / totalEntries) * 100;
  }

  // Получить количество записей, требующих помощи
  int get needHelpEntries {
    return _entries.where((entry) {
      final futureActionParts = entry.futureActions.split('||FA_OPTION:');
      return futureActionParts.length > 1 &&
          futureActionParts[0].trim().toLowerCase() ==
              'не знаю, что делать в подобных ситуациях';
    }).length;
  }

  // Получить процент записей, требующих помощи
  double get needHelpEntriesPercentage {
    if (_entries.isEmpty) return 0;
    return (needHelpEntries / totalEntries) * 100;
  }
}
