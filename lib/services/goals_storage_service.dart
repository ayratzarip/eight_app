import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalsStorageService {
  static const String _goalsKey = 'goals_data';
  static const String _metadataKey = 'goals_metadata';
  static const _uuid = Uuid();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Получить все цели из локального хранилища
  static Future<List<Goal>> getAllGoals() async {
    try {
      final prefs = await _preferences;
      final goalsData = prefs.getString(_goalsKey);

      if (goalsData == null || goalsData.isEmpty) {
        return [];
      }

      // Парсим JSON данные
      final data = jsonDecode(goalsData) as Map<String, dynamic>;
      final goalsJson = data['goals'] as List<dynamic>;

      final goals =
          goalsJson
              .map((json) => Goal.fromJson(json as Map<String, dynamic>))
              .toList();

      // Сортируем по порядку
      goals.sort((a, b) => a.order.compareTo(b.order));

      return goals;
    } catch (e) {
      return [];
    }
  }

  /// Сохранить все цели в локальное хранилище
  static Future<void> _saveAllGoals(List<Goal> goals) async {
    try {
      final prefs = await _preferences;

      // Подготавливаем данные для сохранения
      final dataToSave = {
        'goals': goals.map((goal) => goal.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Сохраняем в SharedPreferences как JSON
      await prefs.setString(_goalsKey, jsonEncode(dataToSave));

      // Сохраняем метаданные
      final metadata = {
        'count': goals.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_metadataKey, jsonEncode(metadata));
    } catch (e) {
      throw Exception('Не удалось сохранить данные: $e');
    }
  }

  /// Добавить новую цель
  static Future<Goal> insertGoal(String text) async {
    final goals = await getAllGoals();
    final now = DateTime.now();
    final id = _uuid.v4();

    // Определяем новый порядковый номер (делаем новую цель первой)
    final minOrder =
        goals.isEmpty
            ? 0
            : goals.map((g) => g.order).reduce((a, b) => a < b ? a : b);
    final newOrder = minOrder - 1;

    final newGoal = Goal(
      id: id,
      text: text,
      isCompleted: false,
      order: newOrder,
      createdAt: now,
      updatedAt: now,
    );

    goals.add(newGoal);
    await _saveAllGoals(goals);

    return newGoal;
  }

  /// Обновить существующую цель
  static Future<void> updateGoal(Goal updatedGoal) async {
    final goals = await getAllGoals();
    final index = goals.indexWhere((goal) => goal.id == updatedGoal.id);

    if (index == -1) {
      throw Exception('Цель с ID ${updatedGoal.id} не найдена');
    }

    // Обновляем цель с новым временем изменения
    goals[index] = updatedGoal.copyWith(updatedAt: DateTime.now());
    await _saveAllGoals(goals);
  }

  /// Удалить цель
  static Future<void> deleteGoal(String id) async {
    final goals = await getAllGoals();
    goals.removeWhere((goal) => goal.id == id);
    await _saveAllGoals(goals);
  }

  /// Обновить порядок целей
  static Future<void> updateGoalOrders(List<Goal> reorderedGoals) async {
    final goals = <Goal>[];

    // Обновляем порядок
    for (int i = 0; i < reorderedGoals.length; i++) {
      final goal = reorderedGoals[i];
      goals.add(goal.copyWith(order: i, updatedAt: DateTime.now()));
    }

    await _saveAllGoals(goals);
  }

  /// Получить метаданные (количество целей, время последнего обновления)
  static Future<Map<String, dynamic>?> getMetadata() async {
    try {
      final prefs = await _preferences;
      final metadataJson = prefs.getString(_metadataKey);

      if (metadataJson == null) {
        return null;
      }

      return jsonDecode(metadataJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Очистить все данные (для отладки или сброса)
  static Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.remove(_goalsKey);
    await prefs.remove(_metadataKey);
  }

  /// Экспорт данных для резервного копирования
  static Future<String?> exportData() async {
    final prefs = await _preferences;
    return prefs.getString(_goalsKey);
  }

  /// Импорт данных из резервной копии
  static Future<void> importData(String jsonData) async {
    try {
      // Проверяем, что данные можно парсить
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final goalsJson = data['goals'] as List<dynamic>;

      // Если парсинг прошел успешно, сохраняем данные
      final prefs = await _preferences;
      await prefs.setString(_goalsKey, jsonData);

      // Обновляем метаданные
      final metadata = {
        'count': goalsJson.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_metadataKey, jsonEncode(metadata));
    } catch (e) {
      throw Exception('Не удалось импортировать данные: $e');
    }
  }
}
