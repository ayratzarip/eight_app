import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';

class DiaryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get allEntries => _entries;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<DiaryEntry> get filteredEntries {
    if (_searchQuery.isEmpty) {
      return _entries;
    }
    return _entries.where((entry) {
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
}
