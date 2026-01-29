import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

const Color kAdviceBg = Color(0xFFe6f4ea);

class AddGoalDialog extends StatefulWidget {
  final Function(String) onAddGoal;

  const AddGoalDialog({super.key, required this.onAddGoal});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onAddGoal(_controller.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка добавления цели: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isLandscape ? 500 : 320,
          maxHeight:
              MediaQuery.of(context).size.height * (isLandscape ? 0.8 : 0.6),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              isLandscape
                  ? 16
                  : 20, // Меньше отступы сверху в горизонтальном режиме
              24,
              isLandscape
                  ? 8
                  : 16, // Меньше отступы снизу в горизонтальном режиме
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  'Добавить новый шаг',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        isLandscape
                            ? 16
                            : 18, // Меньше шрифт в горизонтальном режиме
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 16),
                // Форма
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _controller,
                        autofocus: true,
                        maxLines:
                            isLandscape
                                ? 2
                                : 3, // Меньше строк в горизонтальном режиме
                        minLines: 1,
                        cursorColor: theme.textTheme.bodyLarge?.color,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Введите текст шага...',
                          hintStyle: theme.inputDecorationTheme.hintStyle,
                          border: theme.inputDecorationTheme.border,
                          focusedBorder:
                              theme.inputDecorationTheme.focusedBorder,
                          fillColor: theme.inputDecorationTheme.fillColor,
                          filled: theme.inputDecorationTheme.filled,
                          contentPadding:
                              theme.inputDecorationTheme.contentPadding,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Пожалуйста, введите текст шага';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _addGoal(),
                      ),
                      SizedBox(
                        height: isLandscape ? 8 : 16,
                      ), // Меньше отступы в горизонтальном режиме
                      Container(
                        padding: EdgeInsets.all(
                          isLandscape ? 8 : 12,
                        ), // Меньше отступы в горизонтальном режиме
                        decoration: BoxDecoration(
                          color: kAdviceBg,
                          border: Border.all(
                            color: AppColors.logoGreen.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.logoGreen,
                              size: isLandscape ? 18 : 20,
                            ),
                            SizedBox(
                              width: isLandscape ? 6 : 8,
                            ), // Меньше отступы в горизонтальном режиме
                            Expanded(
                              child: Text(
                                'Совет: Формулируйте шаг конкретно и измеримо',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.logoGreen,
                                  fontSize:
                                      isLandscape
                                          ? 11
                                          : 12, // Меньше шрифт в горизонтальном режиме
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isLandscape ? 12 : 20),
                      // Кнопки действий
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.error,
                              size: isLandscape ? 20 : 24,
                            ),
                            tooltip: 'Отмена',
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: _isLoading ? null : _addGoal,
                            icon:
                                _isLoading
                                    ? SizedBox(
                                      width: isLandscape ? 18 : 20,
                                      height: isLandscape ? 18 : 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.logoGreen,
                                            ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.check,
                                      color: AppColors.logoGreen,
                                      size: isLandscape ? 20 : 24,
                                    ),
                            tooltip: 'Добавить',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
