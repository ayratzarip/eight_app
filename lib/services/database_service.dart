import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static SharedPreferences? _prefs;

  // Проверяем, работаем ли мы в веб-браузере
  bool get isWeb => kIsWeb;

  Future<void> _initStorage() async {
    if (isWeb) {
      _prefs ??= await SharedPreferences.getInstance();
    } else {
      _database ??= await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'logbook.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Таблица записей дневника
    await db.execute('''
      CREATE TABLE diary_entries(
        id TEXT PRIMARY KEY,
        dateTime INTEGER NOT NULL,
        dateMs INTEGER NOT NULL,
        situationDescription TEXT NOT NULL,
        attentionFocus TEXT NOT NULL,
        thoughts TEXT NOT NULL,
        bodySensations TEXT NOT NULL,
        actions TEXT NOT NULL,
        futureActions TEXT NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_dateMs ON diary_entries(dateMs)');
    
    // Таблица целей
    await db.execute('''
      CREATE TABLE goals(
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        order_index INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_goals_order ON goals(order_index)');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Миграция v1 -> v2: добавление поля dateMs
      await db.execute('ALTER TABLE diary_entries ADD COLUMN dateMs INTEGER');
      
      // Заполняем dateMs из dateTime для существующих записей
      final entries = await db.query('diary_entries');
      for (var entry in entries) {
        await db.update(
          'diary_entries',
          {'dateMs': entry['dateTime']},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
      }
    }
    
    if (oldVersion < 3) {
      // Миграция v2 -> v3: изменение типа id с INTEGER на TEXT (UUID)
      // Создаем новую таблицу с правильной структурой
      await db.execute('''
        CREATE TABLE diary_entries_new(
          id TEXT PRIMARY KEY,
          dateTime INTEGER NOT NULL,
          dateMs INTEGER NOT NULL,
          situationDescription TEXT NOT NULL,
          attentionFocus TEXT NOT NULL,
          thoughts TEXT NOT NULL,
          bodySensations TEXT NOT NULL,
          actions TEXT NOT NULL,
          futureActions TEXT NOT NULL
        )
      ''');
      
      // Копируем данные с генерацией UUID для старых записей
      final entries = await db.query('diary_entries');
      for (var entry in entries) {
        final newId = const Uuid().v4();
        await db.insert('diary_entries_new', {
          'id': newId,
          'dateTime': entry['dateTime'],
          'dateMs': entry['dateMs'] ?? entry['dateTime'],
          'situationDescription': entry['situationDescription'],
          'attentionFocus': entry['attentionFocus'],
          'thoughts': entry['thoughts'],
          'bodySensations': entry['bodySensations'],
          'actions': entry['actions'],
          'futureActions': entry['futureActions'],
        });
      }
      
      // Удаляем старую таблицу и переименовываем новую
      await db.execute('DROP TABLE diary_entries');
      await db.execute('ALTER TABLE diary_entries_new RENAME TO diary_entries');
      
      // Создаем индекс
      await db.execute('CREATE INDEX idx_dateMs ON diary_entries(dateMs)');
    }
    
    // Создаем таблицу goals, если её нет
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='goals'"
    );
    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE goals(
          id TEXT PRIMARY KEY,
          text TEXT NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          order_index INTEGER NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_goals_order ON goals(order_index)');
    }
  }
  
  // Геттер для доступа к базе данных (для GoalsStorageService)
  Future<Database> get database async {
    if (isWeb) {
      throw UnsupportedError('SQLite не поддерживается на веб-платформе');
    }
    await _initStorage();
    return _database!;
  }

  // Веб-версия: работа с SharedPreferences
  Future<List<DiaryEntry>> _getEntriesFromPrefs() async {
    final entriesJson = _prefs!.getStringList('diary_entries') ?? [];
    return entriesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return DiaryEntry.fromJson(map);
    }).toList();
  }

  Future<void> _saveEntriesToPrefs(List<DiaryEntry> entries) async {
    final entriesJson =
        entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await _prefs!.setStringList('diary_entries', entriesJson);
  }

  Future<String> insertEntry(DiaryEntry entry) async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      entries.add(entry);
      await _saveEntriesToPrefs(entries);
      return entry.id;
    } else {
      final db = _database!;
      await db.insert('diary_entries', entry.toJson());
      return entry.id;
    }
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      entries.sort((a, b) => b.dateMs.compareTo(a.dateMs));
      return entries;
    } else {
      final db = _database!;
      final List<Map<String, dynamic>> maps = await db.query(
        'diary_entries',
        orderBy: 'dateMs DESC',
      );

      return maps.map((map) => DiaryEntry.fromJson(map)).toList();
    }
  }

  Future<DiaryEntry?> getEntry(String id) async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      try {
        return entries.firstWhere((entry) => entry.id == id);
      } catch (e) {
        return null;
      }
    } else {
      final db = _database!;
      final List<Map<String, dynamic>> maps = await db.query(
        'diary_entries',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return DiaryEntry.fromJson(maps.first);
      }
      return null;
    }
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      final index = entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        entries[index] = entry;
        await _saveEntriesToPrefs(entries);
        return 1;
      }
      return 0;
    } else {
      final db = _database!;
      return await db.update(
        'diary_entries',
        entry.toJson(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  Future<int> deleteEntry(String id) async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      final initialLength = entries.length;
      entries.removeWhere((entry) => entry.id == id);
      await _saveEntriesToPrefs(entries);
      return initialLength - entries.length;
    } else {
      final db = _database!;
      return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<DiaryEntry>> searchEntries(String query) async {
    await _initStorage();

    if (isWeb) {
      // Для веб используем фильтрацию в памяти
      final allEntries = await getAllEntries();
      final lowerQuery = query.toLowerCase();
      return allEntries.where((entry) {
        return entry.situationDescription.toLowerCase().contains(lowerQuery) ||
            entry.attentionFocus.toLowerCase().contains(lowerQuery) ||
            entry.thoughts.toLowerCase().contains(lowerQuery) ||
            entry.bodySensations.toLowerCase().contains(lowerQuery) ||
            entry.actions.toLowerCase().contains(lowerQuery) ||
            entry.futureActions.toLowerCase().contains(lowerQuery);
      }).toList();
    } else {
      // Для SQLite используем SQL LIKE для оптимизации
      final db = _database!;
      final searchPattern = '%$query%';
      final List<Map<String, dynamic>> maps = await db.query(
        'diary_entries',
        where: '''
          situationDescription LIKE ? OR 
          attentionFocus LIKE ? OR 
          thoughts LIKE ? OR 
          bodySensations LIKE ? OR 
          actions LIKE ? OR 
          futureActions LIKE ?
        ''',
        whereArgs: List.filled(6, searchPattern),
        orderBy: 'dateMs DESC',
      );
      return maps.map((map) => DiaryEntry.fromJson(map)).toList();
    }
  }
}
