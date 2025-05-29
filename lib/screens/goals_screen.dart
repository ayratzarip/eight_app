import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../models/goal.dart';
import '../widgets/goal_item.dart';
import '../widgets/add_goal_dialog.dart';
import 'goals_instructions_screen.dart';
import '../main.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isEditMode = false;
  String? _editingGoalId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().loadGoals();
    });
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddGoalDialog(
            onAddGoal: (text) => context.read<GoalsProvider>().addGoal(text),
          ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _editingGoalId = null;
    });
  }

  void _startEditGoal(String goalId) {
    setState(() {
      _editingGoalId = goalId;
    });
  }

  void _saveEditGoal(Goal goal, String newText) {
    context.read<GoalsProvider>().updateGoal(goal, newText);
    setState(() {
      _editingGoalId = null;
    });
  }

  void _cancelEditGoal() {
    setState(() {
      _editingGoalId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 10),
            Text(
              'Soft Skills Engine: Goals',
              style: theme.appBarTheme.titleTextStyle?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.done : Icons.edit_outlined,
              color: theme.textTheme.titleLarge?.color,
            ),
            tooltip: _isEditMode ? 'Завершить редактирование' : 'Редактировать',
            onPressed: _toggleEditMode,
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: theme.textTheme.titleLarge?.color,
            ),
            tooltip: 'Инструкции',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalsInstructionsScreen(),
                ),
              );
            },
          ),
        ],
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
        child: Column(
          children: [
            const SizedBox(height: 90),
            // Статистика и список целей
            Expanded(
              child: Consumer<GoalsProvider>(
                builder: (context, goalsProvider, child) {
                  if (goalsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (goalsProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ошибка загрузки',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goalsProvider.error!,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              goalsProvider.clearError();
                              goalsProvider.loadGoals();
                            },
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }

                  final goals = goalsProvider.sortedGoals;

                  if (goals.isEmpty) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Нет целей',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color:
                                    theme.textTheme.titleLarge?.color ??
                                    Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Почитайте инструкцию, чтобы узнать, как формировать цели, а затем нажмите «Добавить цель», чтобы начать.',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF222B45),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            Center(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3A5BA0),
                                      Color(0xFF6EC6F5),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          theme.textTheme.titleLarge?.color
                                              ?.withValues(alpha: 0.18) ??
                                          Colors.blue.withValues(alpha: 0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const GoalsInstructionsScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.help_outline,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    'Инструкция',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Статистика
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? CustomColors.darkCard
                                  : CustomColors.lightCard,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              'Всего целей',
                              goalsProvider.totalCount.toString(),
                              Icons.psychology_outlined,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            _buildStatItem(
                              context,
                              'Выполнено',
                              goalsProvider.completedCount.toString(),
                              Icons.check_circle_outline,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            _buildStatItem(
                              context,
                              'Прогресс',
                              '${((goalsProvider.completedCount / goalsProvider.totalCount) * 100).round()}%',
                              Icons.trending_up,
                            ),
                          ],
                        ),
                      ),

                      // Список целей
                      Expanded(
                        child:
                            _isEditMode
                                ? ReorderableListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  buildDefaultDragHandles: false,
                                  itemCount: goals.length,
                                  onReorder: (oldIndex, newIndex) {
                                    goalsProvider.reorderGoals(
                                      oldIndex,
                                      newIndex,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final goal = goals[index];
                                    return GoalItem(
                                      key: ValueKey(goal.id),
                                      goal: goal,
                                      isEditMode: _isEditMode,
                                      isEditing: _editingGoalId == goal.id,
                                      isFirst: index == 0 && !goal.isCompleted,
                                      onToggleComplete:
                                          () => goalsProvider
                                              .toggleGoalComplete(goal),
                                      onStartEdit:
                                          () => _startEditGoal(goal.id),
                                      onSaveEdit:
                                          (newText) =>
                                              _saveEditGoal(goal, newText),
                                      onCancelEdit: _cancelEditGoal,
                                      onDelete:
                                          () => goalsProvider.deleteGoal(goal),
                                    );
                                  },
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: goals.length,
                                  itemBuilder: (context, index) {
                                    final goal = goals[index];
                                    return GoalItem(
                                      goal: goal,
                                      isEditMode: _isEditMode,
                                      isEditing: _editingGoalId == goal.id,
                                      isFirst: index == 0 && !goal.isCompleted,
                                      onToggleComplete:
                                          () => goalsProvider
                                              .toggleGoalComplete(goal),
                                      onStartEdit:
                                          () => _startEditGoal(goal.id),
                                      onSaveEdit:
                                          (newText) =>
                                              _saveEditGoal(goal, newText),
                                      onCancelEdit: _cancelEditGoal,
                                      onDelete:
                                          () => goalsProvider.deleteGoal(goal),
                                    );
                                  },
                                ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Нижние кнопки
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка "Журнал"
                  Expanded(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.textTheme.titleLarge?.color?.withValues(
                                  alpha: 0.18,
                                ) ??
                                Colors.blue.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.book_outlined, size: 22),
                        label: const Text(
                          'Журнал',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    ),
                  ),
                  // Кнопка "Добавить цель"
                  Expanded(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A5BA0), Color(0xFF6EC6F5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.textTheme.titleLarge?.color?.withValues(
                                  alpha: 0.18,
                                ) ??
                                Colors.blue.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: _showAddGoalDialog,
                        icon: const Icon(Icons.add, size: 22),
                        label: const Text(
                          'Добавить цель',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
