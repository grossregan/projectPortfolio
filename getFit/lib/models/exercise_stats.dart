// models/exercise_stats.dart

class ExerciseStats {
  final num min;
  final num max;
  final num average;
  final int count;

  ExerciseStats({
    required this.min,
    required this.max,
    required this.average,
    required this.count,
  });

  // Calculate stats from a list of values
  factory ExerciseStats.fromValues(List<num> values) {
    if (values.isEmpty) {
      return ExerciseStats(min: 0, max: 0, average: 0, count: 0);
    }

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final sum = values.fold<num>(0, (a, b) => a + b);
    final avg = sum / values.length;

    return ExerciseStats(
      min: min,
      max: max,
      average: avg,
      count: values.length,
    );
  }
}
