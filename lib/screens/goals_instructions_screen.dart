import 'package:flutter/material.dart';
import 'instructions_screen.dart';
import 'home_screen.dart';
import 'goals_screen.dart';

class GoalsInstructionsScreen extends StatefulWidget {
  const GoalsInstructionsScreen({super.key});

  @override
  State<GoalsInstructionsScreen> createState() =>
      _GoalsInstructionsScreenState();
}

class _GoalsInstructionsScreenState extends State<GoalsInstructionsScreen> {
  final String vimeoVideoUrl =
      'https://player.vimeo.com/video/1234567890'; // Заменить на реальный URL
  int _selectedTab = 2; // 0 - Журнал, 1 - Цели, 2 - Инструкции

  void _onTabTapped(int index) {
    if (index == _selectedTab) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GoalsScreen()),
      );
    }
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Крупный заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Text(
                'Инструкции: цели',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -1,
                ),
              ),
            ),
            // Контент
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                children: [
                  // Контейнер с инструкциями
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23242B) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Видео-инструкция
                        _buildSectionItem(
                          context: context,
                          title: 'Видео-инструкция',
                          description:
                              'Подробное объяснение того, как правильно ставить и достигать цели',
                          icon: Icons.play_circle_outline,
                          isFirst: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VideoPlayerScreen(
                                      videoUrl: vimeoVideoUrl,
                                      title: 'Видео-инструкция',
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildDivider(isDark),
                        // Как формировать цели
                        _buildSectionItem(
                          context: context,
                          title: 'Как формировать цели',
                          description:
                              'Принципы создания эффективных и достижимых целей',
                          icon: Icons.flag_outlined,
                          content: _buildGoalFormationContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Методы достижения
                        _buildSectionItem(
                          context: context,
                          title: 'Методы достижения',
                          description:
                              'Проверенные стратегии для успешного выполнения целей',
                          icon: Icons.trending_up,
                          content: _buildAchievementMethodsContent(
                            context,
                            isDark,
                          ),
                        ),
                        _buildDivider(isDark),
                        // Отслеживание прогресса
                        _buildSectionItem(
                          context: context,
                          title: 'Отслеживание прогресса',
                          description:
                              'Как контролировать движение к цели и корректировать планы',
                          icon: Icons.analytics_outlined,
                          content: _buildProgressTrackingContent(
                            context,
                            isDark,
                          ),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  // Информация о программе EightFaces
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23242B) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Заголовок с логотипом
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Компактный логотип
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.school,
                                          color: kLogoGreen,
                                          size: 24,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Заголовок
                              Text(
                                'EightFaces: Soft Skills Engine',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Описание
                          Text(
                            'Это приложение создано как часть онлайн-программы EightFaces: Soft Skills Engine. Подробнее о курсе — на сайте eightfaces.ru.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _onTabTapped,
        selectedItemColor: kLogoGreen,
        unselectedItemColor: theme.iconTheme.color?.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.stairs), label: 'Цели'),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Инструкции',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white12 : Colors.grey[200],
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSectionItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    Widget? content,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return ExpansionTile(
      tilePadding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 8,
        16,
        content == null ? (isLast ? 16 : 8) : 0,
      ),
      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 16 : 12),
      leading: Icon(icon, color: kLogoGreen, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
      ),
      onExpansionChanged: onTap != null ? (_) => onTap() : null,
      children: content != null ? [content] : [],
    );
  }

  Widget _buildGoalFormationContent(BuildContext context, bool isDark) {
    final principles = [
      '• Конкретность - цель должна быть четко сформулирована',
      '• Измеримость - прогресс должен быть измеримым',
      '• Достижимость - цель должна быть реалистичной',
      '• Релевантность - цель должна быть важной для вас',
      '• Определенность во времени - установите конкретные сроки',
      '• Разбивайте большие цели на подцели',
      '• Записывайте цели и регулярно их пересматривайте',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          principles
              .map(
                (principle) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    principle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildAchievementMethodsContent(BuildContext context, bool isDark) {
    final methods = [
      '• Создавайте план действий с конкретными шагами',
      '• Используйте принцип "малых побед" - начинайте с простого',
      '• Ведите ежедневный учет прогресса',
      '• Найдите партнера по целям для взаимной поддержки',
      '• Визуализируйте достижение цели каждый день',
      '• Награждайте себя за промежуточные достижения',
      '• Изучайте опыт тех, кто уже достиг подобных целей',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          methods
              .map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    method,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildProgressTrackingContent(BuildContext context, bool isDark) {
    final tips = [
      '• Ведите ежедневник для отслеживания действий',
      '• Еженедельно анализируйте прогресс и корректируйте планы',
      '• Используйте метрики для измерения прогресса',
      '• Отмечайте препятствия и ищите способы их преодоления',
      '• Празднуйте достижения, даже маленькие',
      '• Будьте готовы изменить подход, если что-то не работает',
      '• Регулярно напоминайте себе о важности цели',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          tips
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

// Новый экран для видео-инструкции по целям
class GoalsInstructionsVideoScreen extends StatelessWidget {
  const GoalsInstructionsVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VideoPlayerScreen(
      videoUrl:
          'https://player.vimeo.com/video/1234567890', // Заменить на реальный URL
      title: 'Видео: цели',
    );
  }
}
