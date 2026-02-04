import '../models/goal.dart';
import '../models/log.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> insertGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);

  Future<List<Log>> getLogs(String goalId);
  Future<void> insertLog(Log log);
  Future<void> deleteLog(String id);
}
