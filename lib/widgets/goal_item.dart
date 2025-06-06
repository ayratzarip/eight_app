import 'package:flutter/material.dart';
import '../models/goal.dart';

const Color kLogoGreen = Color(0xFF2f855a);

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
    if (query == null || query.isEmpty) {
      return Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: widget.isFirst && !widget.goal.isCompleted ? 18 : 16,
          fontWeight:
              widget.isFirst && !widget.goal.isCompleted
                  ? FontWeight.w600
                  : FontWeight.normal,
          decoration:
              widget.goal.isCompleted ? TextDecoration.lineThrough : null,
          color:
              widget.goal.isCompleted
                  ? Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5)
                  : Theme.of(context).textTheme.bodyLarge?.color,
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
            backgroundColor: kLogoGreen.withValues(alpha: 0.3),
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: widget.isFirst && !widget.goal.isCompleted ? 18 : 16,
          fontWeight:
              widget.isFirst && !widget.goal.isCompleted
                  ? FontWeight.w600
                  : FontWeight.normal,
          decoration:
              widget.goal.isCompleted ? TextDecoration.lineThrough : null,
          color:
              widget.goal.isCompleted
                  ? Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5)
                  : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: widget.isFirst ? 6 : 4,
        borderRadius: BorderRadius.circular(18),
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            border:
                widget.isFirst && !widget.goal.isCompleted
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
          ),
          padding: EdgeInsets.all(
            widget.isFirst && !widget.goal.isCompleted ? 20 : 16,
          ),
          child: Row(
            children: [
              if (widget.isEditMode && !widget.isEditing)
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Container(
                    margin: const EdgeInsets.only(left: 4, right: 12),
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.reorder, color: kLogoGreen, size: 24),
                  ),
                ),

              Checkbox(
                value: widget.goal.isCompleted,
                onChanged:
                    widget.isEditMode && widget.isEditing
                        ? null
                        : (_) => widget.onToggleComplete(),
                activeColor: kLogoGreen,
                checkColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child:
                    widget.isEditing
                        ? TextField(
                          controller: _editController,
                          focusNode: _focusNode,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            border: theme.inputDecorationTheme.border,
                            focusedBorder:
                                theme.inputDecorationTheme.focusedBorder,
                            fillColor: theme.inputDecorationTheme.fillColor,
                            filled: theme.inputDecorationTheme.filled,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _saveEdit(),
                        )
                        : _buildHighlightedText(
                          widget.goal.text,
                          widget.searchQuery,
                        ),
              ),

              if (widget.isEditMode) ...[
                const SizedBox(width: 8),
                if (widget.isEditing) ...[
                  IconButton(
                    icon: Icon(Icons.check, color: theme.colorScheme.primary),
                    onPressed: _saveEdit,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.error),
                    onPressed: widget.onCancelEdit,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: widget.onStartEdit,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _showDeleteConfirmation(context),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ],
          ),
        ),
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
