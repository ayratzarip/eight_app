import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/goals_storage_service.dart';

class GoalsProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Goal> get sortedGoals {
    final sortedList = List<Goal>.from(_goals);
    // Сортируем: незавершенные цели сверху, затем по порядку
    sortedList.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.order.compareTo(b.order);
    });
    return sortedList;
  }

  int get completedCount => _goals.where((goal) => goal.isCompleted).length;
  int get totalCount => _goals.length;

  // Методы аналитики для блока статистики
  int get totalSteps => _goals.length;
  int get pendingSteps => _goals.where((goal) => !goal.isCompleted).length;
  double get completedPercentage {
    if (_goals.isEmpty) return 0;
    return (completedCount / totalCount) * 100;
  }

  /// Загрузить все цели
  Future<void> loadGoals() async {
    _setLoading(true);
    _clearError();

    try {
      _goals = await GoalsStorageService.getAllGoals();
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки целей: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Добавить новую цель
  Future<void> addGoal(String text) async {
    if (text.trim().isEmpty) {
      _setError('Текст цели не может быть пустым');
      return;
    }

    _clearError();

    try {
      final newGoal = await GoalsStorageService.insertGoal(text.trim());
      _goals.add(newGoal);
      notifyListeners();
    } catch (e) {
      _setError('Ошибка добавления цели: $e');
    }
  }

  /// Переключить статус выполнения цели
  Future<void> toggleGoalComplete(Goal goal) async {
    _clearError();

    try {
      final updatedGoal = goal.copyWith(
        isCompleted: !goal.isCompleted,
        updatedAt: DateTime.now(),
      );

      await GoalsStorageService.updateGoal(updatedGoal);

      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка обновления цели: $e');
    }
  }

  /// Обновить текст цели
  Future<void> updateGoal(Goal goal, String newText) async {
    if (newText.trim().isEmpty) {
      _setError('Текст цели не может быть пустым');
      return;
    }

    _clearError();

    try {
      final updatedGoal = goal.copyWith(
        text: newText.trim(),
        updatedAt: DateTime.now(),
      );

      await GoalsStorageService.updateGoal(updatedGoal);

      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка обновления цели: $e');
    }
  }

  /// Удалить цель
  Future<void> deleteGoal(Goal goal) async {
    _clearError();

    try {
      await GoalsStorageService.deleteGoal(goal.id);
      _goals.removeWhere((g) => g.id == goal.id);
      notifyListeners();
    } catch (e) {
      _setError('Ошибка удаления цели: $e');
    }
  }

  /// Изменить порядок целей
  Future<void> reorderGoals(int oldIndex, int newIndex) async {
    _clearError();

    final sortedList = sortedGoals;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final goal = sortedList.removeAt(oldIndex);
    sortedList.insert(newIndex, goal);

    // Обновляем порядок для всех целей
    for (int i = 0; i < sortedList.length; i++) {
      sortedList[i] = sortedList[i].copyWith(order: i);
    }

    // Обновляем локальный список
    _goals = sortedList;
    notifyListeners();

    try {
      await GoalsStorageService.updateGoalOrders(sortedList);
    } catch (e) {
      _setError('Ошибка обновления порядка целей: $e');
      // Перезагружаем цели в случае ошибки
      await loadGoals();
    }
  }

  /// Очистить все данные
  Future<void> clearAllGoals() async {
    _clearError();

    try {
      await GoalsStorageService.clearAllData();
      _goals.clear();
      notifyListeners();
    } catch (e) {
      _setError('Ошибка очистки данных: $e');
    }
  }

  /// Экспорт данных
  Future<String?> exportGoals() async {
    _clearError();

    try {
      return await GoalsStorageService.exportData();
    } catch (e) {
      _setError('Ошибка экспорта данных: $e');
      return null;
    }
  }

  /// Импорт данных
  Future<void> importGoals(String jsonData) async {
    _clearError();

    try {
      await GoalsStorageService.importData(jsonData);
      await loadGoals();
    } catch (e) {
      _setError('Ошибка импорта данных: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
