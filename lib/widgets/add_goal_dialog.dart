import 'package:flutter/material.dart';

const Color kLogoGreen = Color(0xFF2f855a);
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Добавить новый шаг',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Введите текст шага...',
                hintStyle: theme.inputDecorationTheme.hintStyle,
                border: theme.inputDecorationTheme.border,
                focusedBorder: theme.inputDecorationTheme.focusedBorder,
                fillColor: theme.inputDecorationTheme.fillColor,
                filled: theme.inputDecorationTheme.filled,
                contentPadding: theme.inputDecorationTheme.contentPadding,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите текст шага';
                }
                return null;
              },
              onFieldSubmitted: (_) => _addGoal(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAdviceBg,
                border: Border.all(color: kLogoGreen.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: kLogoGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Совет: Формулируйте шаг конкретно и измеримо',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: kLogoGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.redAccent, size: 28),
          tooltip: 'Отмена',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        IconButton(
          icon: Icon(Icons.check, color: kLogoGreen, size: 28),
          tooltip: 'Добавить',
          onPressed: _isLoading ? null : _addGoal,
        ),
      ],
    );
  }
}
