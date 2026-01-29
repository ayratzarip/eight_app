import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../styles/app_styles.dart';

class GoalItem extends StatefulWidget {
  final Goal goal;
  final bool isEditMode;
  final bool isEditing;
  final bool isFirst;
  final int index;
  final VoidCallback onToggleComplete;
  final VoidCallback onStartEdit;
  final Function(String) onSaveEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onDelete;
  final String? searchQuery;

  const GoalItem({
    super.key,
    required this.goal,
    required this.isEditMode,
    required this.isEditing,
    required this.isFirst,
    required this.index,
    required this.onToggleComplete,
    required this.onStartEdit,
    required this.onSaveEdit,
    required this.onCancelEdit,
    required this.onDelete,
    this.searchQuery,
  });

  @override
  State<GoalItem> createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> {
  late TextEditingController _editController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.goal.text);
  }

  @override
  void didUpdateWidget(GoalItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _editController.text = widget.goal.text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final newText = _editController.text.trim();
    if (newText.isNotEmpty) {
      widget.onSaveEdit(newText);
    }
  }

  Widget _buildHighlightedText(String text, String? query) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Стиль для первого незавершенного шага
    final baseFontSize =
        widget.isFirst && !widget.goal.isCompleted ? 17.0 : 15.0;
    final baseFontWeight =
        widget.isFirst && !widget.goal.isCompleted
            ? FontWeight.w600
            : FontWeight.w500;

    if (query == null || query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: baseFontWeight,
          decoration:
              widget.goal.isCompleted ? TextDecoration.lineThrough : null,
          color:
              widget.goal.isCompleted
                  ? (isDark ? Colors.white38 : Colors.grey[400])
                  : (isDark ? Colors.white70 : Colors.black87),
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: AppColors.logoGreen.withValues(alpha: 0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: baseFontWeight,
          decoration:
              widget.goal.isCompleted ? TextDecoration.lineThrough : null,
          color:
              widget.goal.isCompleted
                  ? (isDark ? Colors.white38 : Colors.grey[400])
                  : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Левая зона: чекбокс + отступ для переключения
          GestureDetector(
            onTap: widget.isEditing ? null : () => widget.onToggleComplete(),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: widget.goal.isCompleted,
                  onChanged:
                      widget.isEditMode && widget.isEditing
                          ? null
                          : (_) => widget.onToggleComplete(),
                  activeColor:
                      widget.goal.isCompleted
                          ? AppColors.goalsScreen
                          : AppColors.logoGreen,
                  checkColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Средняя зона: текст для перетаскивания
          if (!widget.isEditing)
            Expanded(
              child: ReorderableDragStartListener(
                index: widget.index,
                child: _buildHighlightedText(
                  widget.goal.text,
                  widget.searchQuery,
                ),
              ),
            )
          else
            Expanded(
              child: TextField(
                controller: _editController,
                focusNode: _focusNode,
                cursorColor: isDark ? Colors.white70 : Colors.black87,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.logoGreen,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.logoGreen,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.logoGreen,
                      width: 2,
                    ),
                  ),
                  fillColor:
                      isDark
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFF5F5F5),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _saveEdit(),
              ),
            ),

          if (widget.isEditing) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.logoGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white, size: 20),
                onPressed: _saveEdit,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.error, size: 20),
              onPressed: widget.onCancelEdit,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ] else ...[
            // В режиме просмотра показываем меню действий
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onStartEdit();
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Удалить цель?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Вы уверены, что хотите удалить цель "${widget.goal.text}"?',
              style: theme.textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }
}
