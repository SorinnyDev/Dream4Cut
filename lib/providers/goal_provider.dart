import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/log.dart';
import '../repositories/goal_repository.dart';
import '../repositories/sqflite_goal_repository.dart';
import 'package:uuid/uuid.dart';

class GoalProvider with ChangeNotifier {
  final GoalRepository _repository;
  List<Goal> _goals = [];
  bool _isLoading = true;
  int _currentTabIndex = 0;

  GoalProvider({GoalRepository? repository})
    : _repository = repository ?? SqfliteGoalRepository() {
    loadGoals();
  }

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals =>
      _goals.where((g) => g.status == GoalStatus.active).toList();
  List<Goal> get completedGoals =>
      _goals.where((g) => g.status == GoalStatus.completed).toList();
  List<Goal> get archivedGoals =>
      _goals.where((g) => g.status == GoalStatus.archived).toList();
  bool get isLoading => _isLoading;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _repository.getGoals();
    _isLoading = false;
    notifyListeners();
  }

  Goal? getGoalAt(int frameIndex, int slotIndex) {
    try {
      return activeGoals.firstWhere(
        (g) => g.frameIndex == frameIndex && g.slotIndex == slotIndex,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Log>> getLogs(String goalId) async {
    return await _repository.getLogs(goalId);
  }

  Future<void> addGoal(
    String title,
    String theme,
    int frameIndex,
    int slotIndex, {
    String? timeCapsuleMessage,
    String? emojiTag,
  }) async {
    final newGoal = Goal(
      id: const Uuid().v4(),
      title: title,
      backgroundTheme: theme,
      totalCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: GoalStatus.active,
      frameIndex: frameIndex,
      slotIndex: slotIndex,
      timeCapsuleMessage: timeCapsuleMessage,
      emojiTag: emojiTag,
    );
    await _repository.insertGoal(newGoal);
    await loadGoals();
  }

  Future<void> addLog(String goalId, String content) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final newIndex = goal.totalCount + 1;

      final newLog = Log(
        id: const Uuid().v4(),
        goalId: goalId,
        content: content,
        actionDate: DateTime.now(),
        createdAt: DateTime.now(),
        index: newIndex,
      );

      await _repository.insertLog(newLog);

      final updatedGoal = goal.copyWith(
        totalCount: newIndex,
        updatedAt: DateTime.now(),
      );

      await _repository.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> completeGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.updateGoal(goal);
    await loadGoals();
  }

  Future<void> archiveGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.archived,
        updatedAt: DateTime.now(),
      );
      await _repository.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> restoreGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.completed,
        updatedAt: DateTime.now(),
      );
      await _repository.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> updateGoalProgress(String id, int newCount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        totalCount: newCount,
        updatedAt: DateTime.now(),
      );
      await _repository.updateGoal(updatedGoal);
      await loadGoals();
    }
  }
}
