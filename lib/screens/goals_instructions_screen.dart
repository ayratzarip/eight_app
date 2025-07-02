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
      'https://player.vimeo.com/video/1059455108?h=33d55d43f5&autoplay=0&loop=0&muted=0&title=1&portrait=0&byline=0&controls=1'; // Обновлённый URL
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
                'Инструкция: цели',
                style: TextStyle(
                  fontSize: 24,
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
                        // Как формировать шаги к цели
                        _buildSectionItem(
                          context: context,
                          title: 'Как формировать шаги к цели',
                          description:
                              'Пошаговое руководство по созданию эффективных шагов к цели',
                          icon: Icons.edit_outlined,
                          content: _buildStepFormationContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Советы и рекомендации
                        _buildSectionItem(
                          context: context,
                          title: 'Советы и рекомендации',
                          description:
                              'Полезные советы для эффективного достижения целей',
                          icon: Icons.lightbulb_outline,
                          content: _buildTipsContent(context, isDark),
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
                              Flexible(
                                child: Text(
                                  'EightFaces: \n Soft Skills Engine',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
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

  Widget _buildStepFormationContent(BuildContext context, bool isDark) {
    final principles = [
      '1. Формируем мечту.',
      '• Представьте, где вы хотите оказаться через 10–20 лет.',
      '• Не ограничивайте себя. Это мечта, а не план.',
      '• Проживите воображаемый день в этом будущем: работа, место, люди рядом.',

      '2. Строим план от конца.',
      '• От мечты — назад, шаг за шагом, пока не дойдёте до того, что реально достижимо через 1–1,5 года.',
      '• Это и будет ваша цель на проект.',

      '3. Формулируем цель.',
      'Цель формулируется по правилу SMART.',
      '• S — Specific (конкретная): цель должна быть чёткой.',
      '• M — Measurable (измеримая): важно понимать, как измерить результат.',
      '• A — Achievable (достижимая): цель должна быть реалистичной.',
      '• R — Relevant (значимая): цель имеет смысл для вас.',
      '• T — Time-bound (ограничена по времени): у цели есть срок.',
      'Записываем цель на соответствующей странице нашего приложения.',

      '4. Продумываем шаги к цели.',
      '• Разбейте путь на мелкие, реалистичные действия.',
      '• Слишком большой шаг = сложно. Слишком маленький = неэффективно.',

      '5. Добавляем тренировочные шаги.',
      '• Придумайте ситуации, где вы чувствуете лёгкую и сильную неловкость.',
      '• Впишите как задания. Упорядочьте их от простого к сложному.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          principles.map((principle) {
            // Проверяем, начинается ли строка с цифры и точки (заголовок пункта)
            final isMainPoint = RegExp(r'^\d+\.\s').hasMatch(principle);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                principle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isMainPoint ? FontWeight.bold : FontWeight.normal,
                  color:
                      isMainPoint
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white70 : Colors.grey[700]),
                  height: 1.4,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTipsContent(BuildContext context, bool isDark) {
    final tips = [
      'Первое правило: мы формируем положительную и конструктивную цель. Тревога и застенчивость становятся проблемами только в том случае, если они стоят на дороге к цели.',
      'Второе правило: план строится от конца, шаг за шагом двигаясь к сегодняшнему дню.',
      'Третье правило: шаги должны быть равномерные и средние, чтобы не уставать и не спотыкаться.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          tips.map((tip) {
            // Находим позицию двоеточия для разделения на жирную и обычную часть
            final colonIndex = tip.indexOf(':');
            if (colonIndex != -1) {
              final boldPart = tip.substring(
                0,
                colonIndex + 1,
              ); // включаем двоеточие
              final regularPart = tip.substring(colonIndex + 1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: boldPart,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      TextSpan(
                        text: regularPart,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Если двоеточие не найдено, отображаем как обычный текст
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              );
            }
          }).toList(),
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
