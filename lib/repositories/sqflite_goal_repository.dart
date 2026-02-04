import '../models/goal.dart';
import '../models/log.dart';
import '../services/database_service.dart';
import 'goal_repository.dart';

class SqfliteGoalRepository implements GoalRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<List<Goal>> getGoals() async {
    return await _dbService.getGoals();
  }

  @override
  Future<void> insertGoal(Goal goal) async {
    await _dbService.insertGoal(goal);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await _dbService.updateGoal(goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _dbService.deleteGoal(id);
  }

  @override
  Future<List<Log>> getLogs(String goalId) async {
    return await _dbService.getLogsByGoalId(goalId);
  }

  @override
  Future<void> insertLog(Log log) async {
    await _dbService.insertLog(log);
  }

  @override
  Future<void> deleteLog(String id) async {
    await _dbService.deleteLog(id);
  }
}
