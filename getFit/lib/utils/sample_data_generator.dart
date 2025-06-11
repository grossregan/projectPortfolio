// utils/sample_data_generator.dart

import 'package:agile_avengers_get_fit/models/exercise_data.dart';

class SampleDataGenerator {
  // Generate sample data for testing
  static List<Map<String, dynamic>> generateSampleData() {
    final exercises = [
      'Squat',
      'Bench Press',
      'Deadlift',
      'Shoulder Press',
      'Pull-ups',
    ];
    final variables = ['Weight', 'Reps', 'Sets', 'RPE', 'Rest Time'];

    final List<Map<String, dynamic>> sampleData = [];

    // Create sample data with realistic progression
    for (final exercise in exercises) {
      for (final variable in variables) {
        // Base value depends on the exercise and variable
        double baseValue = 0;

        // Assign realistic base values
        if (variable == 'Weight') {
          switch (exercise) {
            case 'Squat':
              baseValue = 100;
            case 'Bench Press':
              baseValue = 80;
            case 'Deadlift':
              baseValue = 140;
            case 'Shoulder Press':
              baseValue = 60;
            case 'Pull-ups':
              baseValue = 0; // Bodyweight
          }
        } else if (variable == 'Reps') {
          baseValue = 8;
        } else if (variable == 'Sets') {
          baseValue = 3;
        } else if (variable == 'RPE') {
          baseValue = 7;
        } else if (variable == 'Rest Time') {
          baseValue = 90; // seconds
        }

        // Add multiple entries with small progression for each exercise-variable pair
        for (int i = 0; i < 5; i++) {
          // Add some randomness and progression
          double progression =
              i * (baseValue * 0.05); // 5% progression per entry
          double randomFactor =
              (baseValue * 0.02) * (2 * (DateTime.now().millisecond % 2) - 1);

          double value = baseValue + progression + randomFactor;

          // Round appropriately based on variable type
          if (variable == 'Sets' || variable == 'Reps') {
            value = value.round().toDouble();
          } else if (variable == 'RPE') {
            value = (value * 10).round() / 10; // Round to 1 decimal place
          } else if (variable == 'Weight') {
            value = (value * 2).round() / 2; // Round to nearest 0.5
          }

          sampleData.add({
            'exercise': exercise,
            'variable': variable,
            'value': value,
          });
        }
      }
    }

    return sampleData;
  }

  // Convert raw sample data to ExerciseData objects
  static List<ExerciseData> generateExerciseData() {
    final sampleData = generateSampleData();
    final List<ExerciseData> exerciseDataList = [];

    for (int i = 0; i < sampleData.length; i++) {
      final item = sampleData[i];

      final exercise = item['exercise'] as String;
      final variable = item['variable'] as String;
      final value = item['value'] as num;

      exerciseDataList.add(
        ExerciseData(
          id: 'local-$i',
          exercise: exercise,
          variable: variable,
          value: value,
          timestamp: DateTime.now().subtract(Duration(days: i % 30)),
        ),
      );
    }

    return exerciseDataList;
  }
}
