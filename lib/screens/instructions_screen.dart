import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'home_screen.dart';
import 'goals_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(_getUserAgent())
          ..enableZoom(false)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  setState(() {
                    _hasError = true;
                    _isLoading = false;
                  });
                }
              },
              onPageStarted: (url) {
                debugPrint('Page started loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                }
              },
              onPageFinished: (url) {
                debugPrint('Page finished loading: $url');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.videoUrl));
  }

  String? _getUserAgent() {
    if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
    } else {
      // For Android and other platforms, returning null uses the WebView default User-Agent.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с кнопкой возврата
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: kLogoGreen,
                    ),
                    tooltip: 'Назад',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Баланс для кнопки назад
                ],
              ),
            ),
            // Видео контент
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        Container(
                          color:
                              isDark ? const Color(0xFF23242B) : Colors.white,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Загрузка видео...'),
                              ],
                            ),
                          ),
                        ),
                      if (_hasError)
                        Container(
                          color:
                              isDark ? const Color(0xFF23242B) : Colors.white,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ошибка загрузки видео',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Проверьте подключение к интернету',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _initializeController();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Повторить'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final String vimeoVideoUrl =
      'https://player.vimeo.com/video/1041570908?h=5aaeb04e69&autoplay=0&loop=0&muted=0&title=1&portrait=0&byline=0&controls=1';
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
                'Инструкция: журнал',
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
                              'Подробное объяснение того, как вести журнал самооценки',
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
                        // Как заполнять записи
                        _buildSectionItem(
                          context: context,
                          title: 'Как заполнять записи',
                          description:
                              'Пошаговое руководство по созданию качественных записей',
                          icon: Icons.edit_outlined,
                          content: _buildHowToFillContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Советы и рекомендации
                        _buildSectionItem(
                          context: context,
                          title: 'Советы и рекомендации',
                          description:
                              'Полезные советы для эффективного ведения журнала',
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

  Widget _buildHowToFillContent(BuildContext context, bool isDark) {
    final steps = [
      '1. Описание ситуации - опишите, что произошло максимально подробно',
      '2. Фокус внимания - на чём было сосредоточено ваше внимание в тот момент',
      '3. Мысли - какие мысли у вас возникали, выберите подходящий тип или опишите свои',
      '4. Телесные ощущения - что вы чувствовали в теле, оцените интенсивность',
      '5. Действия - что вы предприняли и каков был результат',
      '6. Планы на будущее - что будете делать в подобных ситуациях',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          steps
              .map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    step,
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

  Widget _buildTipsContent(BuildContext context, bool isDark) {
    final tips = [
      '• Заполняйте записи сразу после события, пока всё свежо в памяти',
      '• Будьте честны с собой, не приукрашивайте и не преуменьшайте',
      '• Обращайте внимание на повторяющиеся паттерны в ваших реакциях',
      '• Регулярно перечитывайте старые записи для анализа прогресса',
      '• Используйте экспорт в CSV для дополнительного анализа данных',
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
