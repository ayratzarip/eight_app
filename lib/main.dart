import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/diary_provider.dart';
import 'providers/goals_provider.dart';
import 'screens/home_screen.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode =
      ThemeMode.system; // Автоматически следуем системной теме
  ThemeMode get themeMode => _themeMode;

  // Убираем toggleTheme, оставляем только системную тему
  ThemeProvider() {
    _themeMode = ThemeMode.system;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации для русского языка
  await initializeDateFormatting('ru', null);

  runApp(const LogbookApp());
}

class LogbookApp extends StatelessWidget {
  const LogbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder:
            (context, themeProvider, _) => MaterialApp(
              title: 'Logbook',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: LightModeColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: LightModeColors.primary, width: 2),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: LightModeColors.surface,
                  shadowColor: Colors.black12,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: LightModeColors.iconColor,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: StadiumBorder(),
                ),
                extensions: <ThemeExtension<dynamic>>[const CustomColors()],
              ),
              darkTheme: ThemeData(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: DarkModeColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DarkModeColors.primary, width: 2),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: DarkModeColors.surface,
                  shadowColor: Colors.black54,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: DarkModeColors.iconColor,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: StadiumBorder(),
                ),
                extensions: <ThemeExtension<dynamic>>[const CustomColors()],
              ),
              home: const HomeScreen(),
            ),
      ),
    );
  }
}

// Цветовая палитра для светлой темы
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

// Цветовая палитра для темной темы
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

// Функция для построения типографики с Google Fonts Inter
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

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors();

  @override
  CustomColors copyWith() => this;
  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) => this;
}
