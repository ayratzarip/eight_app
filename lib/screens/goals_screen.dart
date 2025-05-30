import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../models/goal.dart';
import '../widgets/goal_item.dart';
import '../widgets/add_goal_dialog.dart';
import 'goals_instructions_screen.dart';
import 'home_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isEditMode = false;
  String? _editingGoalId;
  int _selectedTab = 1; // 0 - Журнал, 1 - Цели, 2 - Профиль

  // Добавляем контроллер и состояние для поиска
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().loadGoals();
    });
    // Слушаем изменения в поле поиска
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // Функция фильтрации целей по поисковому запросу
  List<Goal> _filterGoals(List<Goal> goals) {
    if (_searchQuery.isEmpty) {
      return goals;
    }
    return goals
        .where((goal) => goal.text.toLowerCase().contains(_searchQuery))
        .toList();
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

  void _onReorderIncomplete(int oldIndex, int newIndex) {
    // Теперь все незавершенные цели в одном списке
    context.read<GoalsProvider>().reorderGoals(oldIndex, newIndex);
  }

  void _onReorderCompleted(int oldIndex, int newIndex) {
    final allGoals = context.read<GoalsProvider>().sortedGoals;
    final uncompletedCount = allGoals.where((g) => !g.isCompleted).length;

    final globalOldIndex = uncompletedCount + oldIndex;
    final globalNewIndex = uncompletedCount + newIndex;

    context.read<GoalsProvider>().reorderGoals(globalOldIndex, globalNewIndex);
  }

  void _onTabTapped(int index) {
    if (index == _selectedTab) return;
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GoalsInstructionsScreen(),
        ),
      );
    }
    // Для вкладки 'Цели' ничего не делаем
    setState(() {
      _selectedTab = index;
    });
  }

  Widget _buildGoalItem(Goal goal, bool isFirst) {
    return GoalItem(
      key: ValueKey(goal.id),
      goal: goal,
      isEditMode: _isEditMode,
      isEditing: _editingGoalId == goal.id,
      isFirst: isFirst,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      onToggleComplete:
          () => context.read<GoalsProvider>().toggleGoalComplete(goal),
      onStartEdit: () => _startEditGoal(goal.id),
      onSaveEdit: (newText) => _saveEditGoal(goal, newText),
      onCancelEdit: _cancelEditGoal,
      onDelete: () => context.read<GoalsProvider>().deleteGoal(goal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Цвет Tailwind text-green-700
    const Color kLogoGreen = Color(0xFF2f855a);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Крупный заголовок и кнопка +
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Шаги к цели',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isEditMode ? Icons.done : Icons.edit_outlined,
                          size: 24,
                          color: kLogoGreen,
                        ),
                        tooltip:
                            _isEditMode
                                ? 'Завершить редактирование'
                                : 'Редактировать',
                        onPressed: _toggleEditMode,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: kLogoGreen,
                        ),
                        tooltip: 'Добавить цель',
                        onPressed: _showAddGoalDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Строка поиска
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск шагов',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF23242B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Список целей
            Expanded(
              child: Consumer<GoalsProvider>(
                builder: (context, goalsProvider, child) {
                  if (goalsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (goalsProvider.error != null) {
                    return Center(
                      child: Text('Ошибка: ${goalsProvider.error!}'),
                    );
                  }

                  final goals = _filterGoals(goalsProvider.sortedGoals);
                  final uncompletedGoals =
                      goals.where((g) => !g.isCompleted).toList();
                  final completedGoals =
                      goals.where((g) => g.isCompleted).toList();

                  List<Widget> goalBlocks = [];

                  // Если поиск активен и нет результатов
                  if (_searchQuery.isNotEmpty && goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: isDark ? Colors.white38 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Шаги не найдены',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Попробуйте изменить поисковый запрос',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Если нет целей вообще (без поиска)
                  if (_searchQuery.isEmpty && goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stairs,
                            size: 64,
                            color: isDark ? Colors.white38 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Нет шагов к цели',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите + чтобы добавить первый шаг',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Если нет незавершенных целей, но есть завершенные
                  if (_searchQuery.isEmpty &&
                      uncompletedGoals.isEmpty &&
                      completedGoals.isNotEmpty) {
                    goalBlocks.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: const Color(
                                0xFF2f855a,
                              ).withValues(alpha: 0.8),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Все шаги завершены! 🎉',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2f855a),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Отличная работа! Нажмите + чтобы добавить новые цели',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white54 : Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Незавершенные шаги (включая первый)
                  if (uncompletedGoals.isNotEmpty) {
                    goalBlocks.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Найденные шаги (${uncompletedGoals.length})'
                              : 'Следующий шаг',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                    goalBlocks.add(
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF23242B) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:
                            _isEditMode
                                ? ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: uncompletedGoals.length,
                                  onReorder: _onReorderIncomplete,
                                  itemBuilder: (context, index) {
                                    final goal = uncompletedGoals[index];
                                    return _buildGoalItem(goal, index == 0);
                                  },
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: uncompletedGoals.length,
                                  separatorBuilder:
                                      (_, __) => Divider(
                                        height: 1,
                                        color:
                                            isDark
                                                ? Colors.white12
                                                : Colors.grey[200],
                                        thickness: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                  itemBuilder: (context, index) {
                                    final goal = uncompletedGoals[index];
                                    return _buildGoalItem(goal, index == 0);
                                  },
                                ),
                      ),
                    );
                  }

                  // Завершённые шаги
                  if (completedGoals.isNotEmpty) {
                    goalBlocks.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Найденные завершённые шаги (${completedGoals.length})'
                              : 'Завершённые шаги',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                    goalBlocks.add(
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF23242B) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:
                            _isEditMode
                                ? ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: completedGoals.length,
                                  onReorder: _onReorderCompleted,
                                  itemBuilder: (context, index) {
                                    final goal = completedGoals[index];
                                    return _buildGoalItem(goal, false);
                                  },
                                )
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: completedGoals.length,
                                  separatorBuilder:
                                      (_, __) => Divider(
                                        height: 1,
                                        color:
                                            isDark
                                                ? Colors.white12
                                                : Colors.grey[200],
                                        thickness: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                  itemBuilder: (context, index) {
                                    final goal = completedGoals[index];
                                    return _buildGoalItem(goal, false);
                                  },
                                ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    children: goalBlocks,
                  );
                },
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
      floatingActionButton: null, // Кнопка добавления теперь в AppBar
    );
  }
}
