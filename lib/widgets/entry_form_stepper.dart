import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';

enum FormStep {
  situation,
  attention,
  thoughts,
  bodySensations,
  actions,
  futureActions,
}

// Список вариантов для фокуса внимания
const List<String> attentionFocusOptions = [
  'Сконцентрирован на зрительном образе',
  'Сконцентрирован на звуках',
  'Сконцентрирован на смысле',
  'Концентрируюсь на ощущениях своего тела',
  'Погружен в свои мысли',
  'Внимание скачет',
  'Внимание рассеянно',
];

// Список вариантов для мыслей
const List<String> thoughtOptions = [
  'Тревожные мысли будущем "А вдруг...."',
  'Переживания прошлого опыта',
  'Сожаление о прошлом "Ах если бы..."',
  'Ожидание оценки и самооценка',
  'Установки "Я должен..."',
  'Перегрузка планированием',
];

// Новые константы для результатов действий
const List<String> actionResultOptions = [
  'Добились желаемого результата',
  'Не получили желаемый результат',
];
const String actionResultSeparator = "||RESULT:";

// Новые константы для шага "Что делать в будущем?"
const List<String> futureActionOptions = [
  'Знаю, что делать в подобных ситуациях',
  'Не знаю, что делать в подобных ситуациях',
];
const String futureActionOptionSeparator = "||FA_OPTION:";

class EntryFormStepper extends StatefulWidget {
  final DiaryEntry? initialEntry;

  const EntryFormStepper({super.key, this.initialEntry});

  @override
  State<EntryFormStepper> createState() => _EntryFormStepperState();
}

class _EntryFormStepperState extends State<EntryFormStepper> {
  final _pageController = PageController();
  FormStep _currentStep = FormStep.situation;

  // Controllers for text fields
  late TextEditingController _situationController;
  late TextEditingController _attentionController;
  late TextEditingController _thoughtsController;
  late TextEditingController _bodySensationsController;
  late TextEditingController _actionsController;
  late TextEditingController _futureActionsController;

  // Состояние для выбранных вариантов
  String? _selectedAttentionOption;
  String? _selectedThoughtOption;
  String? _selectedActionResult; // Новое состояние для результата действий
  String? _selectedFutureActionOption; // Новое состояние

  // Состояние для слайдера интенсивности телесных ощущений
  double _bodySensationsIntensity = 0.0;

  bool get _isEditing => widget.initialEntry != null;
  DateTime _entryDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Инициализируем все контроллеры
    _situationController = TextEditingController();
    _attentionController = TextEditingController();
    _thoughtsController = TextEditingController();
    _bodySensationsController = TextEditingController();
    _actionsController = TextEditingController();
    _futureActionsController = TextEditingController();
    _entryDateTime = DateTime.now();
    _selectedAttentionOption = null;
    _selectedThoughtOption = null;
    _selectedActionResult = null;
    _selectedFutureActionOption = null; // Инициализация
    _bodySensationsIntensity = 0.0; // По умолчанию для новых записей

    if (_isEditing && widget.initialEntry != null) {
      final entry = widget.initialEntry!;
      _situationController.text = entry.situationDescription;

      // Разбор поля attentionFocus
      final attentionParts = entry.attentionFocus.split('. ');
      if (attentionFocusOptions.contains(attentionParts[0])) {
        _selectedAttentionOption = attentionParts[0];
        _attentionController.text =
            attentionParts.length > 1
                ? attentionParts.sublist(1).join('. ')
                : '';
      } else {
        _selectedAttentionOption = null;
        _attentionController.text = entry.attentionFocus;
      }

      // Разбор поля thoughts
      final thoughtParts = entry.thoughts.split('. ');
      if (thoughtOptions.contains(thoughtParts[0])) {
        _selectedThoughtOption = thoughtParts[0];
        _thoughtsController.text =
            thoughtParts.length > 1 ? thoughtParts.sublist(1).join('. ') : '';
      } else {
        _selectedThoughtOption = null;
        _thoughtsController.text = entry.thoughts;
      }

      // Разбор поля bodySensations для интенсивности и текста
      final bodySensationsFullText = entry.bodySensations;
      final dotIndex = bodySensationsFullText.indexOf('.');

      // Проверяем, что точка есть, она не первый и не последний символ
      if (dotIndex > 0 && dotIndex < bodySensationsFullText.length - 1) {
        final intensityString = bodySensationsFullText.substring(0, dotIndex);
        final descriptionString =
            bodySensationsFullText.substring(dotIndex + 1).trimLeft();
        final parsedIntensity = double.tryParse(intensityString);

        if (parsedIntensity != null &&
            parsedIntensity >= 0 &&
            parsedIntensity <= 10) {
          _bodySensationsIntensity = parsedIntensity;
          _bodySensationsController.text = descriptionString;
        } else {
          // Если парсинг не удался или интенсивность вне диапазона, считаем весь текст описанием
          _bodySensationsController.text = bodySensationsFullText;
          // _bodySensationsIntensity остается значением по умолчанию (0.0)
        }
      } else {
        // Если нет точки или формат неверный, считаем весь текст описанием
        _bodySensationsController.text = bodySensationsFullText;
        // _bodySensationsIntensity остается значением по умолчанию (0.0)
      }

      // Разбор поля actions для текста и результата
      final actionsFullText = entry.actions;
      final separatorIndex = actionsFullText.indexOf(actionResultSeparator);
      if (separatorIndex != -1) {
        _actionsController.text = actionsFullText.substring(0, separatorIndex);
        String result = actionsFullText.substring(
          separatorIndex + actionResultSeparator.length,
        );
        if (actionResultOptions.contains(result)) {
          _selectedActionResult = result;
        }
      } else {
        _actionsController.text = actionsFullText;
      }

      // Разбор поля futureActions
      final futureActionsSavedText = entry.futureActions;
      final faSeparatorIdx = futureActionsSavedText.indexOf(
        futureActionOptionSeparator,
      );

      if (faSeparatorIdx != -1) {
        String option = futureActionsSavedText.substring(0, faSeparatorIdx);
        if (futureActionOptions.contains(option)) {
          _selectedFutureActionOption = option;
        }
        _futureActionsController.text = futureActionsSavedText.substring(
          faSeparatorIdx + futureActionOptionSeparator.length,
        );
      } else {
        // Обработка старых данных или случаев, когда был сохранен только текст или конкретная фраза
        if (futureActionsSavedText == futureActionOptions[1]) {
          // "Не знаю..."
          _selectedFutureActionOption = futureActionOptions[1];
          _futureActionsController.text = "";
        } else if (futureActionsSavedText.isNotEmpty) {
          // Что-то написано, считаем, что "Знаю..."
          _selectedFutureActionOption = futureActionOptions[0];
          _futureActionsController.text = futureActionsSavedText;
        } else {
          // Если было пусто, оставляем _selectedFutureActionOption = null для нового выбора
          _selectedFutureActionOption = null;
          _futureActionsController.text = "";
        }
      }
      _entryDateTime = entry.dateTime;
    } else {
      // Для новых записей контроллеры уже пустые, _entryDateTime - текущее,
      // _bodySensationsIntensity уже 0.0
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _situationController.dispose();
    _attentionController.dispose();
    _thoughtsController.dispose();
    _bodySensationsController.dispose();
    _actionsController.dispose();
    _futureActionsController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    String errorMessage = '';
    bool isValid = true;

    switch (_currentStep) {
      case FormStep.situation:
        if (_situationController.text.trim().isEmpty) {
          errorMessage = 'Пожалуйста, опишите ситуацию.';
          isValid = false;
        }
        break;
      case FormStep.attention:
        if (_selectedAttentionOption == null &&
            _attentionController.text.trim().isEmpty) {
          errorMessage =
              'Пожалуйста, выберите вариант или опишите свой фокус внимания.';
          isValid = false;
        }
        break;
      case FormStep.thoughts:
        if (_selectedThoughtOption == null &&
            _thoughtsController.text.trim().isEmpty) {
          errorMessage = 'Пожалуйста, выберите вариант или опишите свои мысли.';
          isValid = false;
        }
        break;
      case FormStep.bodySensations:
        if (_bodySensationsController.text.trim().isEmpty) {
          errorMessage = 'Пожалуйста, опишите свои телесные ощущения.';
          isValid = false;
        }
        break;
      case FormStep.actions:
        if (_actionsController.text.trim().isEmpty) {
          errorMessage = 'Пожалуйста, опишите свои действия.';
          isValid = false;
        } else if (_selectedActionResult == null) {
          errorMessage = 'Пожалуйста, выберите результат ваших действий.';
          isValid = false;
        }
        break;
      case FormStep.futureActions:
        if (_selectedFutureActionOption == null) {
          errorMessage =
              'Пожалуйста, выберите, знаете ли вы, что делать в будущем.';
          isValid = false;
        } else if (_selectedFutureActionOption ==
                futureActionOptions[0] && // "Знаю..."
            _futureActionsController.text.trim().isEmpty) {
          errorMessage = 'Пожалуйста, опишите, что вы планируете делать.';
          isValid = false;
        }
        break;
    }

    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return isValid;
  }

  void _nextPage() {
    if (!_validateCurrentStep()) return;

    if (_currentStep == FormStep.actions) {
      if (_selectedActionResult == actionResultOptions[0]) {
        _saveEntry();
        return;
      }
    }

    if (_currentStep.index < FormStep.values.length - 1) {
      FormStep nextStepTarget = FormStep.values[_currentStep.index + 1];
      setState(() {
        _currentStep = nextStepTarget;
      });
      _pageController.animateToPage(
        _currentStep.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _saveEntry();
    }
  }

  void _previousPage() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = FormStep.values[_currentStep.index - 1];
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentStep == FormStep.situation) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveEntry() async {
    if ((_currentStep == FormStep.futureActions ||
            // Если мы на шаге Actions и результат "Добились", то валидация уже была в _nextPage
            // и _saveEntry вызвана оттуда. Повторная валидация не нужна.
            // Но если _currentStep НЕ actions (т.е. мы на futureActions), то валидируем.
            (_currentStep != FormStep.actions &&
                _currentStep.index == FormStep.values.length - 1)) &&
        !_validateCurrentStep()) {
      // Валидация для последнего шага (futureActions) или если _nextPage его пропустил
      // Условие сложное, упростим: просто валидируем, если текущий шаг - futureActions
      // или если мы сохраняем с последнего шага (что по сути и есть futureActions)
      if (_currentStep == FormStep.futureActions && !_validateCurrentStep()) {
        return;
      }
    }
    // Более простое условие для валидации перед сохранением:
    // Если мы на последнем шаге (futureActions), или если мы на шаге Actions и выбрали "добились результата"
    // (в этом случае _validateCurrentStep уже была вызвана в _nextPage).
    // Таким образом, здесь нужно валидировать, только если мы на шаге futureActions.
    if (_currentStep == FormStep.futureActions) {
      if (!_validateCurrentStep()) return;
    }

    final diaryProvider = context.read<DiaryProvider>();

    String attentionFocusValue = '';
    if (_selectedAttentionOption != null &&
        _selectedAttentionOption!.isNotEmpty) {
      attentionFocusValue = _selectedAttentionOption!;
      if (_attentionController.text.trim().isNotEmpty) {
        attentionFocusValue += '. ${_attentionController.text.trim()}';
      }
    } else {
      attentionFocusValue = _attentionController.text.trim();
    }

    String thoughtsValue = '';
    if (_selectedThoughtOption != null && _selectedThoughtOption!.isNotEmpty) {
      thoughtsValue = _selectedThoughtOption!;
      if (_thoughtsController.text.trim().isNotEmpty) {
        thoughtsValue += '. ${_thoughtsController.text.trim()}';
      }
    } else {
      thoughtsValue = _thoughtsController.text.trim();
    }

    // Формируем значение для bodySensations
    String bodySensationsValue =
        "${_bodySensationsIntensity.round()}. ${_bodySensationsController.text.trim()}";

    // Формируем значение для actions
    String actionsText = _actionsController.text.trim();
    String fullActionsValue = actionsText;
    if (_selectedActionResult != null && _selectedActionResult!.isNotEmpty) {
      fullActionsValue =
          "$actionsText$actionResultSeparator$_selectedActionResult";
    }

    // Формируем значение для futureActions
    String futureActionsFinalValue = '';
    // Сохраняем futureActions только если не "Добились желаемого результата" на предыдущем шаге
    if (_selectedActionResult != actionResultOptions[0]) {
      if (_selectedFutureActionOption == futureActionOptions[0]) {
        // "Знаю..."
        futureActionsFinalValue =
            "${futureActionOptions[0]}$futureActionOptionSeparator${_futureActionsController.text.trim()}";
      } else if (_selectedFutureActionOption == futureActionOptions[1]) {
        // "Не знаю..."
        futureActionsFinalValue =
            "${futureActionOptions[1]}$futureActionOptionSeparator"; // Текстовое поле не используется
      }
      // Если _selectedFutureActionOption == null (не должно случиться из-за валидации), то futureActionsFinalValue останется пустым
    }

    final entry = DiaryEntry(
      id: _isEditing ? widget.initialEntry!.id : null,
      dateTime: _entryDateTime,
      situationDescription: _situationController.text.trim(),
      attentionFocus: attentionFocusValue,
      thoughts: thoughtsValue,
      bodySensations: bodySensationsValue, // Обновленное значение
      actions: fullActionsValue, // Обновленное значение
      futureActions: futureActionsFinalValue, // Обновленное значение
    );

    try {
      if (_isEditing) {
        await diaryProvider.updateEntry(entry);
      } else {
        await diaryProvider.addEntry(entry);
      }
      if (mounted) {
        Navigator.of(context).pop(); // Close stepper
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Запись обновлена' : 'Запись сохранена'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getStepTitle(FormStep step) {
    switch (step) {
      case FormStep.situation:
        return 'Описание ситуации';
      case FormStep.attention:
        return 'Фокус внимания';
      case FormStep.thoughts:
        return 'Ваши мысли';
      case FormStep.bodySensations:
        return 'Телесные ощущения';
      case FormStep.actions:
        return 'Ваши действия и результат';
      case FormStep.futureActions:
        return 'Что делать в будущем?';
    }
  }

  Widget _buildStep(FormStep step) {
    switch (step) {
      case FormStep.situation:
        return _buildGenericStep(
          step,
          _situationController,
          'Опишите подробно, что произошло...',
          Icons.description,
        );
      case FormStep.attention:
        return _buildAttentionStep();
      case FormStep.thoughts:
        return _buildThoughtsStep();
      case FormStep.bodySensations:
        return _buildBodySensationsStep();
      case FormStep.actions:
        return _buildActionsStep();
      case FormStep.futureActions:
        return _buildFutureActionsStep();
    }
  }

  // ВОССТАНАВЛИВАЕМ _buildGenericStep
  Widget _buildGenericStep(
    FormStep step,
    TextEditingController controller,
    String hintText,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kLogoGreen, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Новый метод для построения UI шага "Фокус внимания"
  Widget _buildAttentionStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedAttentionOption == null
                  ? 'Выберите один из вариантов или опишите свой:'
                  : 'Выбран вариант: "$_selectedAttentionOption". Можете уточнить ниже.',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ...attentionFocusOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 15)),
                value: option,
                groupValue: _selectedAttentionOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedAttentionOption = value;
                  });
                },
                activeColor: kLogoGreen,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _attentionController,
              maxLines: 3,
              minLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText:
                    _selectedAttentionOption == null
                        ? 'На чем было сосредоточено ваше внимание?'
                        : 'Ваши уточнения по фокусу внимания...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kLogoGreen, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Новый метод для построения UI шага "Мысли"
  Widget _buildThoughtsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedThoughtOption == null
                  ? 'Какие мысли у вас возникали? Выберите один из вариантов или опишите свои:'
                  : 'Выбран вариант: "$_selectedThoughtOption".',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            // Список RadioListTile для выбора варианта мыслей
            ...thoughtOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 15)),
                value: option,
                groupValue: _selectedThoughtOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedThoughtOption = value;
                    if (value != null) {
                      // Опционально: очищать текстовое поле при выборе радио-кнопки
                      // _thoughtsController.clear();
                    }
                  });
                },
                activeColor: kLogoGreen,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            // Текстовое поле для дополнительного описания мыслей или основного ввода
            TextField(
              controller: _thoughtsController,
              maxLines: 3,
              minLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText:
                    _selectedThoughtOption == null
                        ? 'Опишите свои мысли подробно...'
                        : 'Ваши уточнения по мыслям...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kLogoGreen, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для цвета текста значения слайдера
  Color _getSliderValueColor(double value) {
    if (value <= 3) return Colors.green.shade700;
    if (value <= 7) return Colors.orange.shade800;
    return Colors.red.shade700;
  }

  // Новый метод для построения UI шага "Телесные ощущения"
  Widget _buildBodySensationsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Оцените интенсивность ощущений:',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment:
                        Alignment.center, // Выравниваем слайдер по центру стека
                    children: [
                      Container(
                        height: 12, // Высота градиентной подложки
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ), // Отступы для ползунка
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.yellow.shade400,
                              Colors.red.shade400,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight:
                              12, // Должна совпадать или быть чуть меньше высоты контейнера
                          activeTrackColor: Colors.transparent,
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: _getSliderValueColor(
                            _bodySensationsIntensity,
                          ).withValues(alpha: 0.7),
                          overlayColor: _getSliderValueColor(
                            _bodySensationsIntensity,
                          ).withAlpha(80),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12.0,
                          ), // Чуть больше для удобства
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20.0,
                          ),
                        ),
                        child: Slider(
                          value: _bodySensationsIntensity,
                          min: 0,
                          max: 10,
                          divisions: 10, // 11 позиций от 0 до 10
                          onChanged: (double value) {
                            setState(() {
                              _bodySensationsIntensity = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _bodySensationsIntensity.round().toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getSliderValueColor(_bodySensationsIntensity),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Опишите ваши телесные ощущения:',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodySensationsController,
              maxLines: 3, // Уменьшил немного для баланса с слайдером
              minLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText:
                    'Что вы чувствовали в теле? (напряжение, дрожь, жар и т.д.)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kLogoGreen, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Новый метод для построения UI шага "Ваши действия"
  Widget _buildActionsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Что вы предприняли? Какие действия совершили?',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _actionsController,
              maxLines: 3,
              minLines: 2,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Опишите ваши действия...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kLogoGreen, width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Каков был результат ваших действий?',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...actionResultOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 15)),
                value: option,
                groupValue: _selectedActionResult,
                onChanged: (String? value) {
                  setState(() {
                    _selectedActionResult = value;
                  });
                },
                activeColor: kLogoGreen,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для построения UI шага "Что делать в будущем?"
  Widget _buildFutureActionsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color kLogoGreen = Color(0xFF2f855a);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Оцените вашу готовность к подобным ситуациям в будущем:',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Генерация RadioListTile для выбора опции
            ...futureActionOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option, style: const TextStyle(fontSize: 15)),
                value: option,
                groupValue: _selectedFutureActionOption,
                onChanged: (String? value) {
                  setState(() {
                    _selectedFutureActionOption = value;
                  });
                },
                activeColor: kLogoGreen,
                contentPadding: EdgeInsets.zero,
              );
            }),

            // Условное отображение текстового поля
            if (_selectedFutureActionOption ==
                futureActionOptions[0]) // "Знаю, что делать в подобных ситуациях"
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что именно вы планируете делать?',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _futureActionsController,
                      maxLines: 3,
                      minLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Опишите ваши будущие шаги...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: kLogoGreen, width: 2),
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF23242B) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Дата и время: ${_entryDateTime.day}.${_entryDateTime.month}.${_entryDateTime.year} ${_entryDateTime.hour}:${_entryDateTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Цвет Tailwind text-green-700
    const Color kLogoGreen = Color(0xFF2f855a);

    String nextButtonText = 'Далее';
    IconData nextButtonIcon = Icons.arrow_forward_ios;
    if (_currentStep == FormStep.actions) {
      if (_selectedActionResult == actionResultOptions[0]) {
        nextButtonText = 'Сохранить';
        nextButtonIcon = Icons.save_alt_outlined;
      }
    } else if (_currentStep == FormStep.futureActions) {
      nextButtonText = 'Сохранить';
      nextButtonIcon = Icons.save_alt_outlined;
    }
    final isFirstStep = _currentStep == FormStep.situation;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Крупный заголовок и кнопка закрытия
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Редактировать запись' : 'Новая запись',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24, color: kLogoGreen),
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Заголовок текущего шага
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                _getStepTitle(_currentStep),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Индикатор прогресса
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: LinearProgressIndicator(
                value:
                    (FormStep.values.indexOf(_currentStep) + 1) /
                    FormStep.values.length,
                backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(kLogoGreen),
                minHeight: 4,
              ),
            ),
            // Контент шага
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = FormStep.values[index];
                  });
                },
                children:
                    FormStep.values.map((step) => _buildStep(step)).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  isFirstStep ? Icons.cancel_outlined : Icons.arrow_back_ios,
                  color: isFirstStep ? Colors.redAccent : kLogoGreen,
                  size: 28,
                ),
                tooltip: isFirstStep ? 'Отменить' : 'Назад',
                onPressed: _previousPage,
              ),
              Text(
                'Шаг ${_currentStep.index + 1} из ${FormStep.values.length}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: Icon(nextButtonIcon, color: kLogoGreen, size: 28),
                tooltip: nextButtonText,
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
