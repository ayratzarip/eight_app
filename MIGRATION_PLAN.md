# План миграции на SQLite по образцу AntiBet

## Анализ текущего состояния

### Текущая реализация:
1. **DiaryEntry**: использует `int? id` (AUTOINCREMENT), `toMap/fromMap`
2. **DatabaseService**: базовая структура SQLite, поиск в памяти, версия 1, без миграций
3. **Goals**: хранятся в SharedPreferences (JSON), не в SQLite
4. **Веб-поддержка**: через SharedPreferences fallback

### Целевая реализация (по образцу):
1. **DiaryEntry**: `String id` (UUID), `toJson/fromJson`, поля `date` и `dateMs`
2. **DatabaseService**: улучшенная структура с индексами, миграции, SQL-поиск
3. **Goals**: миграция в SQLite
4. **Веб-поддержка**: можно оставить SharedPreferences или использовать sqflite_common_ffi_web

---

## Этап 1: Обновление модели DiaryEntry

### 1.1 Изменения в `lib/models/diary_entry.dart`

**Изменения:**
- ✅ Заменить `int? id` на `String id` (обязательное поле)
- ✅ Добавить поле `dateMs` (int) для сортировки
- ✅ Переименовать `toMap()` → `toJson()`
- ✅ Переименовать `fromMap()` → `fromJson()`
- ✅ Обновить `copyWith()` для новых полей
- ✅ Добавить генерацию UUID при создании (если id не указан)

**Код:**
```dart
import 'package:uuid/uuid.dart';

class DiaryEntry {
  final String id;
  final DateTime dateTime;
  final int dateMs; // Для сортировки
  final String situationDescription;
  final String attentionFocus;
  final String thoughts;
  final String bodySensations;
  final String actions;
  final String futureActions;

  DiaryEntry({
    String? id,
    DateTime? dateTime,
    required this.situationDescription,
    required this.attentionFocus,
    required this.thoughts,
    required this.bodySensations,
    required this.actions,
    required this.futureActions,
  })  : id = id ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now(),
        dateMs = (dateTime ?? DateTime.now()).millisecondsSinceEpoch;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'dateMs': dateMs,
      'situationDescription': situationDescription,
      'attentionFocus': attentionFocus,
      'thoughts': thoughts,
      'bodySensations': bodySensations,
      'actions': actions,
      'futureActions': futureActions,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        json['dateMs'] as int? ?? json['dateTime'] as int,
      ),
      situationDescription: json['situationDescription'] as String? ?? '',
      attentionFocus: json['attentionFocus'] as String? ?? '',
      thoughts: json['thoughts'] as String? ?? '',
      bodySensations: json['bodySensations'] as String? ?? '',
      actions: json['actions'] as String? ?? '',
      futureActions: json['futureActions'] as String? ?? '',
    );
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? dateTime,
    String? situationDescription,
    String? attentionFocus,
    String? thoughts,
    String? bodySensations,
    String? actions,
    String? futureActions,
  }) {
    final newDateTime = dateTime ?? this.dateTime;
    return DiaryEntry(
      id: id ?? this.id,
      dateTime: newDateTime,
      situationDescription: situationDescription ?? this.situationDescription,
      attentionFocus: attentionFocus ?? this.attentionFocus,
      thoughts: thoughts ?? this.thoughts,
      bodySensations: bodySensations ?? this.bodySensations,
      actions: actions ?? this.actions,
      futureActions: futureActions ?? this.futureActions,
    );
  }
}
```

---

## Этап 2: Обновление DatabaseService

### 2.1 Новая структура таблицы

**Создание таблицы:**
```sql
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
);

CREATE INDEX idx_dateMs ON diary_entries(dateMs);
```

### 2.2 Миграции базы данных

**Версии:**
- v1 → v2: Добавление поля `dateMs`, миграция существующих данных
- v2 → v3: Изменение типа `id` с INTEGER на TEXT (UUID)

**Код миграций:**
```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    // Добавляем поле dateMs
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
    // Миграция id с INTEGER на TEXT (UUID)
    // Это сложная миграция, требует создания новой таблицы
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
    
    // Копируем данные с генерацией UUID
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
}
```

### 2.3 Улучшенный поиск через SQL

**Текущий поиск** (в памяти):
```dart
Future<List<DiaryEntry>> searchEntries(String query) async {
  final allEntries = await getAllEntries();
  return allEntries.where((entry) => ...).toList();
}
```

**Новый поиск** (через SQL LIKE):
```dart
Future<List<DiaryEntry>> searchEntries(String query) async {
  final db = await database;
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
```

### 2.4 Обновление методов CRUD

**Изменения:**
- `insertEntry()`: возвращает `String id` вместо `int`
- `getEntry()`: принимает `String id` вместо `int`
- `updateEntry()`: использует `String id`
- `deleteEntry()`: принимает `String id` вместо `int`
- Все методы используют `toJson/fromJson` вместо `toMap/fromMap`

---

## Этап 3: Миграция Goals в SQLite

### 3.1 Создание таблицы goals

```sql
CREATE TABLE goals(
  id TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  order_index INTEGER NOT NULL,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL
);

CREATE INDEX idx_goals_order ON goals(order_index);
```

### 3.2 Обновление GoalsStorageService

**Изменения:**
- Использовать DatabaseService для работы с SQLite
- Сохранить SharedPreferences fallback для веб (опционально)
- Обновить все методы для работы с SQLite

**Новая структура:**
```dart
class GoalsStorageService {
  static final DatabaseService _dbService = DatabaseService();
  
  static Future<List<Goal>> getAllGoals() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'goals',
      orderBy: 'order_index ASC',
    );
    return maps.map((map) => Goal.fromJson(map)).toList();
  }
  
  // ... остальные методы
}
```

---

## Этап 4: Обновление провайдеров

### 4.1 DiaryProvider

**Изменения:**
- `deleteEntry(int id)` → `deleteEntry(String id)`
- Обновить все вызовы методов с учетом новых типов

### 4.2 GoalsProvider

**Изменения:**
- Минимальные, так как Goals уже использует String id
- Убедиться, что все методы работают корректно

---

## Этап 5: Обновление UI компонентов

### 5.1 Файлы, требующие изменений:

1. **lib/screens/entry_detail_screen.dart**
   - Обновить типы id с `int` на `String`

2. **lib/screens/add_edit_entry_screen.dart**
   - Обновить работу с id

3. **lib/widgets/entry_form_stepper.dart**
   - Обновить создание/обновление записей

4. **lib/screens/home_screen.dart**
   - Обновить передачу id в методы

---

## Этап 6: Зависимости

### 6.1 Проверка зависимостей

**Текущие:**
- ✅ `sqflite: ^2.3.0` - уже есть
- ✅ `uuid: ^4.2.1` - уже есть
- ✅ `path: ^1.8.3` - уже есть

**Дополнительно (для веб, опционально):**
- `sqflite_common_ffi: ^2.3.0` - для desktop
- `sqflite_common_ffi_web: ^1.0.0` - для web

---

## Порядок выполнения миграции

1. ✅ **Этап 1**: Обновить модель DiaryEntry
2. ✅ **Этап 2**: Обновить DatabaseService с миграциями
3. ✅ **Этап 3**: Мигрировать Goals в SQLite
4. ✅ **Этап 4**: Обновить провайдеры
5. ✅ **Этап 5**: Обновить UI компоненты
6. ✅ **Этап 6**: Тестирование и проверка

---

## Важные замечания

### Миграция данных
- При обновлении с версии 1 на версию 3 нужно будет мигрировать существующие данные
- Рекомендуется создать скрипт миграции для пользователей с существующими данными

### Веб-поддержка
- Можно оставить SharedPreferences для веб или использовать sqflite_common_ffi_web
- Текущая реализация с SharedPreferences работает, но не оптимальна

### Производительность
- Индексы на `dateMs` улучшат сортировку
- SQL-поиск вместо фильтрации в памяти улучшит производительность

---

## Тестирование

После миграции необходимо протестировать:
1. ✅ Создание новых записей
2. ✅ Редактирование записей
3. ✅ Удаление записей
4. ✅ Поиск записей
5. ✅ Сортировка по дате
6. ✅ Работа с целями
7. ✅ Миграция существующих данных (если есть)
