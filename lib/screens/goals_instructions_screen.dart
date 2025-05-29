import 'package:flutter/material.dart';
import '../main.dart';
import 'instructions_screen.dart';

class GoalsInstructionsScreen extends StatelessWidget {
  const GoalsInstructionsScreen({super.key});

  final String vimeoVideoUrl =
      'https://player.vimeo.com/video/1234567890'; // Заменить на реальный URL

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? CustomColors.darkGradientStart
                  : CustomColors.lightGradientStart,
              isDark
                  ? CustomColors.darkGradientEnd
                  : CustomColors.lightGradientEnd,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF3A5BA0),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Инструкции: цели',
                    style: Theme.of(
                      context,
                    ).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.blue,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.blue,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Видео-инструкция
                    Text(
                      'Видео-инструкция',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? CustomColors.darkCard
                                : CustomColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color
                                    ?.withValues(alpha: 0.06) ??
                                Colors.blue.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color
                                          ?.withValues(alpha: 0.18) ??
                                      Colors.blue.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(40),
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
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Посмотреть видео-инструкцию',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color ??
                                  Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Подробное объяснение того, как правильно ставить и достигать цели',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.white70 : Color(0xFF222B45),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Блок "Как формировать цели"
                    Text(
                      'Как формировать цели',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? CustomColors.darkCard
                                : CustomColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color
                                    ?.withValues(alpha: 0.06) ??
                                Colors.blue.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ставьте цели по принципам SMART: конкретные, измеримые, достижимые, релевантные и ограниченные во времени. Это поможет вам развивать soft skills более эффективно.',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white : Color(0xFF222B45),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _instructionRow(
                            context,
                            Icons.center_focus_strong,
                            'Specific — Конкретные',
                            'Цель должна быть ясной и понятной. Например: "Провести презентацию проекта".',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.straighten,
                            'Measurable — Измеримые',
                            'Должна быть возможность оценить результат. Например: "3 встречи с клиентами".',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.trending_up,
                            'Achievable — Достижимые',
                            'Цель должна быть реалистичной с учётом ваших возможностей и ресурсов.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.track_changes,
                            'Relevant — Релевантные',
                            'Цель должна соответствовать вашим потребностям в развитии soft skills.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.schedule,
                            'Time-bound — Ограниченные во времени',
                            'Установите конкретный срок выполнения. Например: "до конца недели".',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Блок "Что означают иконки"
                    Text(
                      'Что означают иконки',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _iconCard(
                      context,
                      Icons.add_circle_outline,
                      'Добавить цель',
                      'Создаёт новую цель в списке.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.check_circle_outline,
                      'Отметить выполнение',
                      'Отмечает цель как выполненную или невыполненную.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.edit,
                      'Редактировать',
                      'Позволяет изменить текст существующей цели.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.delete,
                      'Удалить',
                      'Удаляет выбранную цель из списка.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.drag_indicator,
                      'Перетаскивание',
                      'Позволяет изменить порядок целей в режиме редактирования.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.analytics_outlined,
                      'Статистика',
                      'Показывает общее количество целей и процент выполнения.',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _instructionRow(
    BuildContext context,
    IconData icon,
    String title,
    String text,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      Colors.blue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Color(0xFF222B45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconCard(
    BuildContext context,
    IconData icon,
    String title,
    String text,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CustomColors.darkCard : CustomColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(
                  context,
                ).textTheme.titleLarge?.color?.withValues(alpha: 0.06) ??
                Colors.blue.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? CustomColors.darkText : Color(0xFF222B45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
