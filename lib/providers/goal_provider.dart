import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

import '../models/log.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Goal> _goals = [];
  bool _isLoading = true;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals =>
      _goals.where((g) => g.status == GoalStatus.active).toList();
  List<Goal> get completedGoals =>
      _goals.where((g) => g.status == GoalStatus.completed).toList();
  List<Goal> get archivedGoals =>
      _goals.where((g) => g.status == GoalStatus.archived).toList();
  bool get isLoading => _isLoading;

  GoalProvider() {
    loadGoals();
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    _goals = await _dbService.getGoals();
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Log>> getLogs(String goalId) async {
    return await _dbService.getLogsByGoalId(goalId);
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

      await _dbService.insertLog(newLog);

      final updatedGoal = goal.copyWith(
        totalCount: newIndex,
        updatedAt: DateTime.now(),
      );

      await _dbService.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> addGoal(
    String title,
    String theme,
    int frameIndex,
    int slotIndex,
  ) async {
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
    );
    await _dbService.insertGoal(newGoal);
    await loadGoals();
  }

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> completeGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _dbService.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> archiveGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.archived,
        updatedAt: DateTime.now(),
      );
      await _dbService.updateGoal(updatedGoal);
      await loadGoals();
    }
  }

  Future<void> restoreGoal(String id) async {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      // 보관된 목표를 복원하면 발걸음(completed) 앨범으로 이동하거나 다시 활성화?
      // 요청에 따르면 "서랍에서 복원하면 [발걸음] 탭의 앨범으로 이동"
      final updatedGoal = _goals[goalIndex].copyWith(
        status: GoalStatus.completed,
        updatedAt: DateTime.now(),
      );
      await _dbService.updateGoal(updatedGoal);
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
      await _dbService.updateGoal(updatedGoal);
      await loadGoals();
    }
  }
}
