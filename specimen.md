# AntiBet - Техническая спецификация проекта

## 1. Технический стек

### Платформа и язык
- **Flutter SDK**: ^3.6.0
- **Dart**: ^3.6.0
- **Material Design 3**: Включен (`useMaterial3: true`)

### Основные зависимости

#### UI и навигация
- `flutter` (SDK) - Основной фреймворк
- `cupertino_icons: ^1.0.8` - iOS-стиль иконки
- `google_fonts: ^6.1.0` - Шрифты Google Fonts (Inter)
- `go_router: ^16.2.0` - Навигация и роутинг
- `provider: ^6.1.2` - Управление состоянием

#### Хранение данных
- `sqflite: ^2.0.0` - SQLite для мобильных платформ
- `sqflite_common_ffi: ^2.3.0` - Поддержка desktop платформ
- `sqflite_common_ffi_web: ^1.0.0` - Поддержка web платформы
- `path: ^1.0.0` - Работа с путями файловой системы
- `uuid: ^4.0.0` - Генерация уникальных идентификаторов

#### Утилиты
- `intl: 0.20.2` - Интернационализация и форматирование дат
- `csv: ^6.0.0` - Экспорт данных в CSV формат
- `share_plus: ^12.0.0` - Поделиться данными (экспорт)

### Dev зависимости
- `flutter_test` - Тестирование
- `flutter_lints: ^5.0.0` - Линтинг кода
- `flutter_launcher_icons: ^0.13.1` - Генерация иконок приложения

---

## 2. Хранение информации в SQLite

### Архитектура хранения

Приложение использует локальную базу данных SQLite для хранения всех записей дневника. Данные хранятся исключительно на устройстве пользователя, без облачной синхронизации.

### Модель данных

#### Класс `DiaryEntry`

```dart
class DiaryEntry {
  final String id;
  final DateTime date;
  final String place;
  final String company;
  final String circumstances;
  final String trigger;
  final String thoughts;
  final String sensations;
  final String intensity;
  final String actions;
  final String consequences;

  DiaryEntry({
    String? id,
    DateTime? date,
    required this.place,
    required this.company,
    required this.circumstances,
    required this.trigger,
    required this.thoughts,
    required this.sensations,
    required this.intensity,
    required this.actions,
    this.consequences = '',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();
}
```

#### Сериализация в JSON

```dart
Map<String, dynamic> toJson() => {
  'id': id,
  // В БД храним человекочитаемую дату в привычном RU-формате
  // и отдельное поле для корректной сортировки/фильтрации.
  'date': _ruDateTimeFormat.format(date),
  'dateMs': date.millisecondsSinceEpoch,
  'place': place,
  'company': company,
  'circumstances': circumstances,
  'trigger': trigger,
  'thoughts': thoughts,
  'sensations': sensations,
  'intensity': intensity,
  'actions': actions,
  'consequences': consequences,
};
```

#### Десериализация из JSON

```dart
factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
  id: json['id'] as String,
  date: _parseDateFromDb(json),
  place: json['place'] as String,
  company: json['company'] as String,
  circumstances: json['circumstances'] as String,
  trigger: json['trigger'] as String,
  thoughts: json['thoughts'] as String,
  sensations: json['sensations'] as String,
  intensity: (json['intensity'] as String?) ?? '',
  actions: json['actions'] as String,
  consequences: (json['consequences'] as String?) ?? '',
);
```

### Структура базы данных

#### Создание таблицы



**Особенности структуры:**
- `id` - UUID, первичный ключ
- `dateMs` - Timestamp в миллисекундах для сортировки
- `date` - Человекочитаемая дата в формате `dd.MM.yyyy HH:mm`
- Все текстовые поля обязательны, кроме `consequences` (по умолчанию пустая строка)
- Индекс на `dateMs` для быстрой сортировки по дате

### Инициализация базы данных

```dart
Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'antibet.db');
  
  return await openDatabase(
    path,
    version: 4,
    onCreate: (db, version) async {
      // Создание таблицы (код выше)
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // Миграции версий
    },
  );
}
```

### Миграции базы данных

Приложение поддерживает миграции для обновления структуры БД:

```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    // Миграция v1 -> v2: добавление поля dateMs
    await db.execute('ALTER TABLE diary_entries ADD COLUMN dateMs INTEGER');
    // Заполнение dateMs из существующих записей
    // ...
  }
  if (oldVersion < 3) {
    // Миграция v2 -> v3: добавление поля intensity
    await db.execute(
      'ALTER TABLE diary_entries ADD COLUMN intensity TEXT NOT NULL DEFAULT ""'
    );
  }
  if (oldVersion < 4) {
    // Миграция v3 -> v4: добавление поля consequences
    await db.execute(
      'ALTER TABLE diary_entries ADD COLUMN consequences TEXT NOT NULL DEFAULT ""'
    );
  }
}
```

### CRUD операции

#### Вставка записи

```dart
Future<void> insertEntry(DiaryEntry entry) async {
  final db = await database;
  await db.insert(
    'diary_entries',
    entry.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
```

#### Обновление записи

```dart
Future<void> updateEntry(DiaryEntry entry) async {
  final db = await database;
  await db.update(
    'diary_entries',
    entry.toJson(),
    where: 'id = ?',
    whereArgs: [entry.id],
  );
}
```

#### Получение всех записей

```dart
Future<List<DiaryEntry>> getAllEntries() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'diary_entries',
    orderBy: 'dateMs DESC', // Сортировка по дате (новые сверху)
  );
  return maps.map((map) => DiaryEntry.fromJson(map)).toList();
}
```

#### Поиск записей

```dart
Future<List<DiaryEntry>> searchEntries(String query) async {
  final db = await database;
  final searchPattern = '%$query%';
  final List<Map<String, dynamic>> maps = await db.query(
    'diary_entries',
    where: '''
      place LIKE ? OR 
      company LIKE ? OR 
      circumstances LIKE ? OR 
      trigger LIKE ? OR 
      thoughts LIKE ? OR 
      sensations LIKE ? OR 
      intensity LIKE ? OR 
      actions LIKE ? OR 
      consequences LIKE ?
    ''',
    whereArgs: List.filled(9, searchPattern),
    orderBy: 'dateMs DESC',
  );
  return maps.map((map) => DiaryEntry.fromJson(map)).toList();
}
```

#### Удаление записи

```dart
Future<void> deleteEntry(String id) async {
  final db = await database;
  await db.delete(
    'diary_entries',
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

### Singleton паттерн для DatabaseService

```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
}
```

---

## 3. Дизайн-система

### Цветовая палитра

#### Светлая тема (LightModeColors)

```dart
class LightModeColors {
  // Фон 90% светлоты
  static const background = Color(0xFFE6E6E6);
  // Карточки 95% светлоты
  static const surface = Color(0xFFF2F2F2);

  // Текст основной 5% светлоты
  static const textPrimary = Color(0xFF0D0D0D);
  // Текст второстепенный 30% светлоты
  static const textMuted = Color(0xFF4D4D4D);

  // Кнопки внутри карточек 100% (белый)
  static const primary = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFF0D0D0D);

  // Поля для ввода 100% (белый)
  static const inputField = Color(0xFFFFFFFF);

  // Цвет текста кнопок 70% светлоты
  static const buttonText = Color(0xFFB3B3B3);

  // Цвет фона вторичных кнопок 95% светлоты
  static const secondaryButtonBackground = Color(0xFFF2F2F2);
  // Цвет текста вторичных кнопок 30% светлоты
  static const secondaryButtonText = Color(0xFF4D4D4D);

  // Цвет иконок и индикаторов
  static const iconColor = Color(0xFF2b67dc);

  static const border = Color(0xFFE5E5EA);
}
```

#### Темная тема (DarkModeColors)

```dart
class DarkModeColors {
  // Фон 10% светлоты
  static const background = Color(0xFF1A1A1A);
  // Карточки 5% светлоты
  static const surface = Color(0xFF0D0D0D);

  // Текст основной 95% светлоты
  static const textPrimary = Color(0xFFF2F2F2);
  // Текст второстепенный 70% светлоты
  static const textMuted = Color(0xFFB3B3B3);

  // Кнопки внутри карточек 0% (черный)
  static const primary = Color(0xFF000000);
  static const onPrimary = Color(0xFFF2F2F2);

  // Поля для ввода 0% (черный)
  static const inputField = Color(0xFF000000);

  // Цвет текста кнопок 30% светлоты
  static const buttonText = Color(0xFF4D4D4D);

  // Цвет фона вторичных кнопок 5% светлоты
  static const secondaryButtonBackground = Color(0xFF0D0D0D);
  // Цвет текста вторичных кнопок 70% светлоты
  static const secondaryButtonText = Color(0xFFB3B3B3);

  // Цвет иконок и индикаторов
  static const iconColor = Color(0xFF2b67dc);

  static const border = Color(0xFF2C2C2E);
}
```

### Типографика

#### Шрифт: Google Fonts Inter

```dart
TextTheme _buildTextTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final primaryColor =
      isDark ? DarkModeColors.textPrimary : LightModeColors.textPrimary;

  return TextTheme(
    // Display стили
    displayLarge: GoogleFonts.inter(
        fontSize: 57, fontWeight: FontWeight.bold, color: primaryColor),
    displayMedium: GoogleFonts.inter(
        fontSize: 45, fontWeight: FontWeight.bold, color: primaryColor),
    displaySmall: GoogleFonts.inter(
        fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),

    // Headline стили (с отрицательным letterSpacing)
    headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -0.5),
    headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -0.5),
    headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5),

    // Title стили
    titleLarge: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w700, color: primaryColor),
    titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
    titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),

    // Body стили
    bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: primaryColor),
    bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: primaryColor),
    bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? DarkModeColors.textMuted : LightModeColors.textMuted),
  );
}
```

### Spacing и Radius

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
```

### Тема приложения

#### Светлая тема

```dart
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.background,
  colorScheme: const ColorScheme.light(
    primary: LightModeColors.primary,
    onPrimary: LightModeColors.onPrimary,
    secondary: LightModeColors.primary,
    onSecondary: LightModeColors.onPrimary,
    secondaryContainer: Color(0xFFE5E5EA),
    onSecondaryContainer: LightModeColors.textPrimary,
    surface: LightModeColors.surface,
    onSurface: LightModeColors.textPrimary,
    onSurfaceVariant: LightModeColors.textMuted,
    surfaceContainerHighest: Color(0xFFE5E5EA),
    outline: LightModeColors.border,
  ),
  textTheme: _buildTextTheme(Brightness.light),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: LightModeColors.primary,
      foregroundColor: LightModeColors.onPrimary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightModeColors.inputField,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: LightModeColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: LightModeColors.primary, width: 2),
    ),
  ),
);
```

#### Темная тема

```dart
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.background,
  colorScheme: const ColorScheme.dark(
    primary: DarkModeColors.primary,
    onPrimary: DarkModeColors.onPrimary,
    secondary: DarkModeColors.primary,
    onSecondary: DarkModeColors.onPrimary,
    secondaryContainer: Color(0xFF2C2C2E),
    onSecondaryContainer: DarkModeColors.textPrimary,
    surface: DarkModeColors.surface,
    onSurface: DarkModeColors.textPrimary,
    onSurfaceVariant: DarkModeColors.textMuted,
    surfaceContainerHighest: Color(0xFF2C2C2E),
    outline: DarkModeColors.border,
  ),
  textTheme: _buildTextTheme(Brightness.dark),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DarkModeColors.primary,
      foregroundColor: DarkModeColors.onPrimary,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkModeColors.inputField,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: DarkModeColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: DarkModeColors.primary, width: 2),
    ),
  ),
);
```

### UI Компоненты

#### 1. GradientCard - Карточка с градиентной каймой

```dart
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.backgroundColor,
    this.radius = 12,
    this.borderWidth = 1.25,
    this.simulateLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Градиент каймы
    LinearGradient borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary.withValues(alpha: isDark ? 0.50 : 0.45),
        secondary.withValues(alpha: isDark ? 0.45 : 0.40),
      ],
    );

    final shadowOpacity = isDark ? 0.35 : 0.08;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: borderGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - borderWidth),
          child: Material(
            color: backgroundColor ?? cs.surface,
            child: child,
          ),
        ),
      ),
    );
  }
}
```

**Использование:**
```dart
GradientCard(
  radius: AppRadius.md,
  child: Padding(
    padding: AppSpacing.paddingMd,
    child: Text('Содержимое карточки'),
  ),
)
```

#### 2. Основные кнопки (FilledButton)

##### Первичная кнопка (белая/черная)

```dart
FilledButton.icon(
  onPressed: () => _saveEntry(),
  icon: const Icon(Icons.save),
  label: const Text('Сохранить запись'),
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

##### Вторичная кнопка (серая)

```dart
FilledButton.icon(
  onPressed: _exportData,
  icon: Icon(
    Icons.share,
    color: Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.iconColor
        : LightModeColors.iconColor,
  ),
  label: const Text('Экспорт CSV'),
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.secondaryButtonBackground
        : LightModeColors.secondaryButtonBackground,
    foregroundColor: Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.secondaryButtonText
        : LightModeColors.secondaryButtonText,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

##### Кнопка с акцентным цветом

```dart
FilledButton.icon(
  onPressed: () => _showHelpBottomSheet(key),
  icon: Icon(
    Icons.lightbulb_outline,
    color: Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.iconColor
        : LightModeColors.iconColor,
  ),
  label: const Text('Посмотреть примеры'),
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

#### 3. Поля ввода (TextField)

##### Поле ввода в визарде (белое/черное, без окаймления)

```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.inputField
        : LightModeColors.inputField,
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  clipBehavior: Clip.antiAlias,
  child: TextField(
    controller: controller,
    autofocus: true,
    keyboardType: TextInputType.multiline,
    textCapitalization: TextCapitalization.sentences,
    maxLines: null,
    minLines: 6,
    decoration: InputDecoration(
      hintText: 'Ваш ответ...',
      hintStyle: TextStyle(
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: AppSpacing.paddingMd,
    ),
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
          fontSize: 16,
        ),
  ),
)
```

##### Поле ввода в форме (с окаймлением)

```dart
TextFormField(
  controller: controller,
  maxLines: maxLines,
  decoration: InputDecoration(
    hintText: optional
        ? 'Введите $label... (необязательно)'
        : 'Введите $label...',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
  ),
  validator: (value) {
    if (optional) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите $label';
    }
    return null;
  },
)
```

#### 4. Слайдер интенсивности

```dart
Widget _buildIntensitySlider() {
  final progress = _intensityValue / 10.0;
  final color = Color.lerp(Colors.green, Colors.red, progress)!;

  return Padding(
    padding: AppSpacing.paddingLg,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Фоновый градиент — по центру, на одной линии с треком слайдера
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.red],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Слайдер поверх градиента
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: color,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                overlayColor: color.withValues(alpha: 0.12),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                value: _intensityValue,
                min: 0,
                max: 10,
                label: _intensityValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _intensityValue = value;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

#### 5. Иконки с акцентными цветами

```dart
Color _iconAccent(BuildContext context, IconData icon) {
  if (icon == Icons.people || icon == Icons.psychology) {
    return _accentTeal; // Color(0xFF08B0BB)
  }
  if (icon == Icons.warning_amber_rounded || icon == Icons.speed) {
    return _accentOrange; // Color(0xFFFFA000)
  }
  if (icon == Icons.favorite_border) {
    return Theme.of(context).colorScheme.error;
  }
  if (icon == Icons.check_circle_outline) {
    return _accentTeal;
  }
  if (icon == Icons.place || icon == Icons.lightbulb_outline) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeColors.iconColor
        : LightModeColors.iconColor;
  }
  // Нейтральные иконки
  return Theme.of(context).colorScheme.onSurfaceVariant;
}
```

**Использование:**
```dart
Icon(
  Icons.psychology,
  color: _iconAccent(context, Icons.psychology),
)
```

#### 6. Индикатор шагов (Step Indicator)

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(9, (index) {
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isCurrent ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isCompleted || isCurrent
            ? (Theme.of(context).brightness == Brightness.dark
                ? DarkModeColors.iconColor
                : LightModeColors.iconColor)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }),
)
```

### Применение темы в приложении

```dart
MaterialApp.router(
  title: 'AntiBet - Recovery Diary',
  debugShowCheckedModeBanner: false,
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system, // Автоматическое переключение по системным настройкам
  routerConfig: AppRouter.router,
)
```

---

## Заключение

Проект AntiBet использует современный стек Flutter с Material Design 3, локальное хранение данных через SQLite и продуманную дизайн-систему с поддержкой светлой и темной тем. Все данные хранятся локально на устройстве пользователя, обеспечивая максимальную приватность.
