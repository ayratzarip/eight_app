import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/diary_provider.dart';
import 'providers/goals_provider.dart';
import 'screens/home_screen.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации для русского языка
  await initializeDateFormatting('ru', null);

  runApp(const SoftSkillsLogbookApp());
}

class SoftSkillsLogbookApp extends StatelessWidget {
  const SoftSkillsLogbookApp({super.key});

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
              title: 'Soft Skills Engine: Logbook',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                useMaterial3: true,
                fontFamily:
                    'Nunito', // Современный шрифт, можно заменить на Inter/Roboto
                colorScheme: ColorScheme(
                  brightness: Brightness.light,
                  primary: const Color(
                    0xFF3A5BA0,
                  ), // глубокий синий из логотипа
                  onPrimary: Colors.white,
                  secondary: const Color(0xFF6EC6F5), // светло-голубой акцент
                  onSecondary: Colors.white,
                  error: Colors.red,
                  onError: Colors.white,
                  surface: Colors.white,
                  onSurface: const Color(0xFF222B45),
                ),
                scaffoldBackgroundColor: const Color(0xFFF6F8FB),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  foregroundColor: Color(0xFF222B45),
                  titleTextStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF222B45),
                    letterSpacing: 0.5,
                  ),
                  iconTheme: IconThemeData(color: Color(0xFF3A5BA0)),
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
                  color: Colors.white,
                  shadowColor: Colors.black12,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color(0xFF3A5BA0),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: StadiumBorder(),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF3A5BA0),
                      width: 2,
                    ),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                textTheme: const TextTheme(
                  titleLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF172554),
                  ),
                  headlineSmall: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF172554),
                  ),
                  titleMedium: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF172554),
                  ),
                  bodyLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: Color(0xFF222B45),
                  ),
                  bodyMedium: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    color: Color(0xFF3A5BA0),
                  ),
                  labelLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF3A5BA0),
                  ),
                ),
                extensions: <ThemeExtension<dynamic>>[const CustomColors()],
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                fontFamily: 'Nunito',
                colorScheme: ColorScheme(
                  brightness: Brightness.dark,
                  primary: const Color(0xFF6EC6F5),
                  onPrimary: Colors.black,
                  secondary: const Color(0xFF3A5BA0),
                  onSecondary: Colors.white,
                  error: Colors.red[400]!,
                  onError: Colors.black,
                  surface: const Color(0xFF232A3B),
                  onSurface: Colors.white,
                ),
                scaffoldBackgroundColor: const Color(0xFF181C24),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  foregroundColor: Colors.white,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  iconTheme: IconThemeData(color: Color(0xFF6EC6F5)),
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
                  color: const Color(0xFF232A3B),
                  shadowColor: Colors.black54,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Color(0xFF6EC6F5),
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shape: StadiumBorder(),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF6EC6F5),
                      width: 2,
                    ),
                  ),
                  fillColor: const Color(0xFF232A3B),
                  filled: true,
                  hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                textTheme: const TextTheme(
                  titleLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFFDBEAFE),
                  ),
                  headlineSmall: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFDBEAFE),
                  ),
                  titleMedium: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFFDBEAFE),
                  ),
                  bodyLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  bodyMedium: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    color: Color(0xFF6EC6F5),
                  ),
                  labelLarge: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF6EC6F5),
                  ),
                ),
                extensions: <ThemeExtension<dynamic>>[const CustomColors()],
              ),
              home: const HomeScreen(),
            ),
      ),
    );
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors();

  // Светлая тема
  static const lightGradientStart = Color(0xFFF2F2F7);
  static const lightGradientEnd = Color(0xFFE5E5EA);
  static const lightCard = Colors.white;
  static const lightText = Color(0xFF1C1C1E);

  // Тёмная тема
  static const darkGradientStart = Color(0xFF1C1C1E);
  static const darkGradientEnd = Color(0xFF2C2C2E);
  static const darkCard = Colors.black;
  static const darkText = Colors.white;

  @override
  CustomColors copyWith() => this;
  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) => this;
}
