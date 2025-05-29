import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3A5BA0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.blue,
          ),
        ),
        centerTitle: true,
      ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: WebViewWidget(
                controller:
                    WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.parse(videoUrl)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  final String vimeoVideoUrl = 'https://player.vimeo.com/video/1041570908';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double videoHeight = screenWidth / (16 / 9);
    if (videoHeight > 400) videoHeight = 400;
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
                    'Инструкции: журнал',
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
                            'Подробное объяснение того, как правильно заполнять журнал самонаблюдения',
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
                    // Блок "Как вести журнал"
                    Text(
                      'Как вести журнал',
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
                            'Заполняйте журнал, когда хотите проанализировать сложную, важную или эмоциональную ситуацию. Это поможет лучше понять себя и свои реакции.',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white : Color(0xFF222B45),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _instructionRow(
                            context,
                            Icons.center_focus_strong,
                            'Фокус внимания',
                            'Опишите, на чём было сосредоточено ваше внимание в ситуации. Можно выбрать вариант или описать свой.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.psychology,
                            'Мысли',
                            'Запишите мысли, которые возникали в момент ситуации. Можно выбрать из списка или добавить свои.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.accessibility_new,
                            'Телесные ощущения',
                            'Оцените интенсивность ощущений с помощью слайдера и опишите, что чувствовали в теле.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.directions_run,
                            'Действия и результат',
                            'Опишите, что вы предприняли, и выберите результат: добились ли желаемого.',
                          ),
                          const SizedBox(height: 12),
                          _instructionRow(
                            context,
                            Icons.lightbulb,
                            'Что делать в будущем',
                            'Выберите, знаете ли вы, что делать в подобных ситуациях, и опишите свои будущие шаги, если знаете.',
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
                      Icons.save_alt_outlined,
                      'Сохранить',
                      'Сохраняет новую или отредактированную запись.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.edit,
                      'Редактировать',
                      'Позволяет изменить существующую запись.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.delete,
                      'Удалить',
                      'Удаляет выбранную запись из журнала.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.download_outlined,
                      'Экспорт',
                      'Экспортирует все ваши записи в CSV-файл.',
                    ),
                    const SizedBox(height: 12),
                    _iconCard(
                      context,
                      Icons.help_outline,
                      'Инструкции',
                      'Открывает этот раздел с подсказками.',
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
