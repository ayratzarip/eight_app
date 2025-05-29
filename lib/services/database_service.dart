import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    String path = join(await getDatabasesPath(), 'diary_entries.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime INTEGER NOT NULL,
        situationDescription TEXT NOT NULL,
        attentionFocus TEXT NOT NULL,
        thoughts TEXT NOT NULL,
        bodySensations TEXT NOT NULL,
        actions TEXT NOT NULL,
        futureActions TEXT NOT NULL
      )
    ''');
  }

  // Веб-версия: работа с SharedPreferences
  Future<List<DiaryEntry>> _getEntriesFromPrefs() async {
    final entriesJson = _prefs!.getStringList('diary_entries') ?? [];
    return entriesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return DiaryEntry.fromMap(map);
    }).toList();
  }

  Future<void> _saveEntriesToPrefs(List<DiaryEntry> entries) async {
    final entriesJson =
        entries.map((entry) => jsonEncode(entry.toMap())).toList();
    await _prefs!.setStringList('diary_entries', entriesJson);
  }

  Future<int> _getNextId() async {
    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      if (entries.isEmpty) return 1;
      return entries.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    } else {
      // Для SQLite ID генерируется автоматически
      return 0;
    }
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      final newId = await _getNextId();
      final newEntry = entry.copyWith(id: newId);
      entries.add(newEntry);
      await _saveEntriesToPrefs(entries);
      return newId;
    } else {
      final db = _database!;
      return await db.insert('diary_entries', entry.toMap());
    }
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    await _initStorage();

    if (isWeb) {
      final entries = await _getEntriesFromPrefs();
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return entries;
    } else {
      final db = _database!;
      final List<Map<String, dynamic>> maps = await db.query(
        'diary_entries',
        orderBy: 'dateTime DESC',
      );

      return List.generate(maps.length, (i) {
        return DiaryEntry.fromMap(maps[i]);
      });
    }
  }

  Future<DiaryEntry?> getEntry(int id) async {
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
        return DiaryEntry.fromMap(maps.first);
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
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  Future<int> deleteEntry(int id) async {
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
  }
}
