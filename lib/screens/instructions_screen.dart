import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'home_screen.dart';
import 'goals_screen.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
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
              child: Text('Инструкции', style: theme.textTheme.headlineSmall),
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
                        // Как пользоваться приложением
                        _buildSectionItem(
                          context: context,
                          title: 'Как пользоваться приложением',
                          description:
                              'Основные функции и возможности приложения Logbook',
                          icon: Icons.phone_android,
                          iconColor: AppColors.instructionsScreen,
                          isFirst: true,
                          content: _buildHowToUseAppContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Как заполнять журнал
                        _buildSectionItem(
                          context: context,
                          title: 'Как заполнять журнал',
                          description:
                              'Пошаговое руководство по заполнению журнала самонаблюдения',
                          icon: Icons.book_outlined,
                          iconColor: AppColors.logoGreen,
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
                          iconColor: AppColors.logoGreen,
                          content: _buildTipsContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Как формировать шаги к цели
                        _buildSectionItem(
                          context: context,
                          title: 'Как формировать шаги к цели',
                          description:
                              'Пошаговое руководство по созданию эффективных шагов к цели',
                          icon: Icons.stairs_outlined,
                          iconColor: AppColors.goalsScreen,
                          content: _buildStepFormationContent(context, isDark),
                        ),
                        _buildDivider(isDark),
                        // Советы и рекомендации по целям
                        _buildSectionItem(
                          context: context,
                          title: 'Советы и рекомендации по целям',
                          description:
                              'Полезные советы для эффективного достижения целей',
                          icon: Icons.lightbulb_outline,
                          iconColor: AppColors.goalsScreen,
                          content: _buildGoalsTipsContent(context, isDark),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  // Первое предупреждение
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Theme.of(context).colorScheme.error,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Внимание! Удаление приложения приведет к безвозвратной потере всех записей, так как они хранятся только на устройстве.',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Второе предупреждение
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: const Color(0xFFFFA000),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Это приложение является инструментом самопомощи и не заменяет профессиональную терапию или медицинское лечение.',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark ? Colors.white54 : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
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
        selectedItemColor: AppColors.instructionsScreen,
        unselectedItemColor: theme.iconTheme.color?.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Журнал',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stairs_outlined),
            label: 'Цели',
          ),
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
    required Color iconColor,
    bool isFirst = false,
    bool isLast = false,
    Widget? content,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExpansionTile(
      tilePadding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 8,
        16,
        content == null ? (isLast ? 16 : 8) : 0,
      ),
      childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 16 : 12),
      leading: Icon(icon, color: iconColor, size: 24),
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

  Widget _buildHowToUseAppContent(BuildContext context, bool isDark) {
    final instructions = [
      'I. Создание новых записей',
      '• На экране "Журнал" нажмите кнопку "+ Новая запись" в правом нижнем углу;',
      '• Заполните все шаги формы по порядку;',
      '• На каждом шаге вы можете вернуться назад или закрыть форму;',
      '• После заполнения всех полей нажмите "Сохранить".',

      'II. Редактирование записей',
      '• На экране "Журнал" нажмите на карточку записи для просмотра;',
      '• В детальном просмотре нажмите иконку редактирования (карандаш) или выберите "Редактировать" в меню (три точки);',
      '• Внесите необходимые изменения;',
      '• Сохраните изменения кнопкой "Сохранить".',

      'III. Работа с шагами к цели',
      '• На экране "Шаги к цели" нажмите кнопку "+ Новый шаг" для добавления новой цели;',
      '• Для редактирования шага нажмите на три точки в карточке и выберите "Редактировать";',
      '• Для перемещения шагов: зажмите среднюю часть карточки и перетащите её в нужное место;',
      '• Для отметки выполнения: нажмите на чекбокс слева от текста шага;',
      '• Первый шаг в списке выделен жирным шрифтом — это ваш следующий шаг.',

      'IV. Экспорт данных',
      '• На экране "Журнал" нажмите кнопку "Экспорт CSV";',
      '• Данные будут экспортированы в формате CSV;',
      '• Вы сможете открыть файл в Excel, Google Sheets или другом редакторе таблиц;',
      '• Экспорт включает все записи с датами, описаниями и всеми заполненными полями.',

      'V. Копирование для AI',
      '• На экране "Журнал" нажмите кнопку "Копировать для AI";',
      '• Все ваши записи будут отформатированы и скопированы в буфер обмена;',
      '• Вставьте текст в любой AI-ассистент для анализа;',
      '• AI поможет выявить паттерны, дать рекомендации и ответить на вопросы о ваших записях.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          instructions.map((instruction) {
            // Проверяем, является ли строка заголовком раздела (римские цифры)
            final isMainSection = RegExp(r'^[IVX]+\.\s').hasMatch(instruction);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                instruction,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isMainSection ? FontWeight.bold : FontWeight.normal,
                  color:
                      isMainSection
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white70 : Colors.grey[700]),
                  height: 1.4,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHowToFillContent(BuildContext context, bool isDark) {
    final steps = [
      'I. Дата и время',
      'Записываются автоматически.',

      'II. Описание ситуации',
      '• записывайте кратко, ключевыми словами;',
      '• не перегружайте деталями — запись должна быть понятной при повторном чтении.',

      'III. Фокус внимания',
      'Определите, на чём вы сконцентрированы:',
      '1. Сконцентрирован на зрительном образе.',
      '2. Сконцентрирован на звуках.',
      '3. Сконцентрирован на смысле.',
      '4. Концентрируюсь на ощущениях своего тела.',
      '5. Погружен в свои мысли.',
      '6. Внимание скачет.',
      '7. Внимание рассеянно.',
      'Первые три считаем желательными.',

      'IV. Мысли',
      'Если не «слышите» свои мысли, то можно:',
      '• записать самое логичное, что подошло бы под ситуацию;',
      '• представить себя персонажем комикса — и записать, что было бы в облачке.',
      'Виды мыслей:',
      '1. Тревожные мысли о будущем («А вдруг...»).',
      '2. Переживания прошлого опыта.',
      '3. Сожаление о прошлом («Ах если бы...»).',
      '4. Ожидание оценки и самооценка.',
      '5. Установки («Я должен...»).',
      '6. Перегрузка планированием.',
      '7. Мыслил «линейно».',
      'Последний считаем желательным.',

      'V. Телесные ощущения',
      'Осознаём телесную реакцию на происходящее. Для этого:',
      '• просканируйте мышцы тела снизу вверх, оценивая напряжение, обращайте внимание на мышцы брюшного пресса, надплечья, заднюю поверхность шеи, мышцы лица;',
      '• обратите внимание на дыхание;',
      '• обратите внимание на сердцебиение;',
      '• обратите внимание на ощущения в животе и малом тазу;',
      '• просканируйте ощущения с кожи.',
      'Оцените интенсивность ощущений по шкале от 0 до 10.',

      'VI. Ваши действия и результат',
      '• запишите действия кратко, но ясно;',
      '• отметьте: достигли ли желаемого результата или нет.',

      'VII. Что делать в будущем?',
      '• если не знаете — нажмите «Не знаю» и сохраните (можно обсудить позже);',
      '• если знаете — запишите, как будете действовать в следующий раз.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          steps.map((step) {
            // Проверяем, является ли строка заголовком раздела (римские цифры)
            final isMainSection = RegExp(r'^[IVX]+\.\s').hasMatch(step);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isMainSection ? FontWeight.bold : FontWeight.normal,
                  color:
                      isMainSection
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
      'Журнал — это инструмент наблюдения и анализа, а не просто дневник.',
      'Журнал нужен чтобы:',
      '• разделять эмоции, мысли и фокус внимания;',
      '• замечать эмоции, мысли и фокус внимания;',
      '• выявлять паттерны поведения;',
      '• отслеживать прогресс;',
      '• лучше готовиться к повторным попыткам после неудач.',
      'Когда заполнять:',
      '• первые 2–3 недели: каждый контакт (в том числе онлайн) и каждое изменение настроения;',
      '• во время провокации социальной тревоги;',
      '• после каждого неудачного или удачного взаимодействия;',
      '• во время выполнения упражнений.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          tips.map((tip) {
            // Проверяем, является ли строка заголовком подраздела
            final isSubHeader =
                tip == 'Журнал нужен чтобы:' || tip == 'Когда заполнять:';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSubHeader ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSubHeader
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white70 : Colors.grey[700]),
                  height: 1.4,
                ),
              ),
            );
          }).toList(),
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

  Widget _buildGoalsTipsContent(BuildContext context, bool isDark) {
    final tips = [
      'Первое правило:',
      'Мы формируем положительную и конструктивную цель. Тревога и застенчивость становятся проблемами только в том случае, если они стоят на дороге к цели.',
      'Второе правило:',
      'План строится от конца, шаг за шагом двигаясь к сегодняшнему дню.',
      'Третье правило:',
      'Шаги должны быть равномерные и средние, чтобы не уставать и не спотыкаться.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          tips.map((tip) {
            // Проверяем, является ли строка заголовком правила (заканчивается на "правило:")
            final isRuleHeader = tip.endsWith('правило:');

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isRuleHeader ? FontWeight.bold : FontWeight.normal,
                  color:
                      isRuleHeader
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white70 : Colors.grey[700]),
                  height: 1.4,
                ),
              ),
            );
          }).toList(),
    );
  }
}
