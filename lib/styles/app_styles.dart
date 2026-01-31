import 'package:flutter/material.dart';

/// Константы цветов приложения
class AppColors {
  static const Color logoGreen = Color(0xFF2f855a);

  // Цвета для экранов навигации
  static const Color journalScreen = Color(0xFF006B7D); // Журнал
  static const Color goalsScreen = Color(0xFF319795); // Шаги к цели
  static const Color instructionsScreen = Color(0xFF3182ce); // Информация

  // Приватный конструктор, чтобы предотвратить создание экземпляров
  AppColors._();
}

/// Константы радиусов скругления
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 18.0;

  AppRadius._();
}

/// Готовые стили для кнопок приложения
class AppButtonStyles {
  /// Стиль для основных кнопок действий (Экспорт CSV, Копировать для AI)
  static ButtonStyle primaryAction(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
    );
  }

  /// Стиль для плавающих кнопок добавления (Новая запись, Новый шаг)
  static ButtonStyle floatingAction(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      minimumSize: const Size(0, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }

  /// Стиль для вторичных кнопок (если понадобится в будущем)
  static ButtonStyle secondary(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return FilledButton.styleFrom(
      backgroundColor:
          isDark
              ? const Color(0xFF2C2C2E) // Пример для темной темы
              : Colors.grey[200],
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
    );
  }

  AppButtonStyles._();
}

/// Готовые стили для полей ввода
class AppInputStyles {
  /// Стиль для стандартных полей ввода в формах
  static InputDecoration standard({
    required BuildContext context,
    required String hintText,
    IconData? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.logoGreen, width: 2),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
    );
  }

  /// Стиль для полей ввода с выделением (например, при редактировании цели)
  static InputDecoration highlighted({
    required BuildContext context,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.logoGreen, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.logoGreen, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: const BorderSide(color: AppColors.logoGreen, width: 2),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
    );
  }

  AppInputStyles._();
}

/// Готовые стили для карточек
class AppCardStyles {
  /// Стандартный стиль для карточек записей и целей
  static BoxDecoration standard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? const Color(0xFF23242B) : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  AppCardStyles._();
}

/// Готовые стили для текста
class AppTextStyles {
  /// Стиль для заголовков экранов
  static TextStyle screenTitle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.headlineSmall ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  }

  /// Стиль для подзаголовков
  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white70 : Colors.grey[600],
    );
  }

  /// Стиль для меток даты и времени
  static TextStyle dateTime(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      color: isDark ? Colors.white70 : Colors.grey[600],
    );
  }

  AppTextStyles._();
}
