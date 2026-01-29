import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import 'database_service.dart';

class GoalsStorageService {
  static const String _goalsKey = 'goals_data';
  static const String _metadataKey = 'goals_metadata';
  static const _uuid = Uuid();

  static SharedPreferences? _prefs;
  static final DatabaseService _dbService = DatabaseService();

  static bool get isWeb => kIsWeb;

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Получить все цели из локального хранилища
  static Future<List<Goal>> getAllGoals() async {
    if (isWeb) {
      return await _getGoalsFromPrefs();
    } else {
      return await _getGoalsFromDatabase();
    }
  }

  static Future<List<Goal>> _getGoalsFromPrefs() async {
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

  static Future<List<Goal>> _getGoalsFromDatabase() async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'goals',
        orderBy: 'order_index ASC',
      );
      return maps.map((map) => _mapToGoal(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static Goal _mapToGoal(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      text: map['text'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      order: map['order_index'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  static Map<String, dynamic> _goalToMap(Goal goal) {
    return {
      'id': goal.id,
      'text': goal.text,
      'isCompleted': goal.isCompleted ? 1 : 0,
      'order_index': goal.order,
      'createdAt': goal.createdAt.millisecondsSinceEpoch,
      'updatedAt': goal.updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Сохранить все цели в локальное хранилище
  static Future<void> _saveAllGoals(List<Goal> goals) async {
    if (isWeb) {
      await _saveGoalsToPrefs(goals);
    } else {
      await _saveGoalsToDatabase(goals);
    }
  }

  static Future<void> _saveGoalsToPrefs(List<Goal> goals) async {
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

  static Future<void> _saveGoalsToDatabase(List<Goal> goals) async {
    try {
      final db = await _dbService.database;
      final batch = db.batch();
      
      // Удаляем все существующие цели
      batch.delete('goals');
      
      // Вставляем новые цели
      for (var goal in goals) {
        batch.insert('goals', _goalToMap(goal));
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Не удалось сохранить данные: $e');
    }
  }

  /// Добавить новую цель
  static Future<Goal> insertGoal(String text) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    if (isWeb) {
      final goals = await getAllGoals();
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
    } else {
      final db = await _dbService.database;
      final goals = await getAllGoals();
      
      // Определяем новый порядковый номер
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

      await db.insert('goals', _goalToMap(newGoal));
      return newGoal;
    }
  }

  /// Обновить существующую цель
  static Future<void> updateGoal(Goal updatedGoal) async {
    final goal = updatedGoal.copyWith(updatedAt: DateTime.now());
    
    if (isWeb) {
      final goals = await getAllGoals();
      final index = goals.indexWhere((g) => g.id == goal.id);

      if (index == -1) {
        throw Exception('Цель с ID ${goal.id} не найдена');
      }

      goals[index] = goal;
      await _saveAllGoals(goals);
    } else {
      final db = await _dbService.database;
      final count = await db.update(
        'goals',
        _goalToMap(goal),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      
      if (count == 0) {
        throw Exception('Цель с ID ${goal.id} не найдена');
      }
    }
  }

  /// Удалить цель
  static Future<void> deleteGoal(String id) async {
    if (isWeb) {
      final goals = await getAllGoals();
      goals.removeWhere((goal) => goal.id == id);
      await _saveAllGoals(goals);
    } else {
      final db = await _dbService.database;
      await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    }
  }

  /// Обновить порядок целей
  static Future<void> updateGoalOrders(List<Goal> reorderedGoals) async {
    if (isWeb) {
      // Для веба используем стандартный метод сохранения
      final goals = <Goal>[];
      for (int i = 0; i < reorderedGoals.length; i++) {
        final goal = reorderedGoals[i];
        goals.add(goal.copyWith(order: i, updatedAt: DateTime.now()));
      }
      await _saveAllGoals(goals);
    } else {
      // Для базы данных используем batch update для эффективности
      final db = await _dbService.database;
      final batch = db.batch();
      
      for (int i = 0; i < reorderedGoals.length; i++) {
        final goal = reorderedGoals[i];
        final updatedGoal = goal.copyWith(order: i, updatedAt: DateTime.now());
        batch.update(
          'goals',
          {
            'order_index': updatedGoal.order,
            'updatedAt': updatedGoal.updatedAt.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [updatedGoal.id],
        );
      }
      
      await batch.commit(noResult: true);
    }
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
