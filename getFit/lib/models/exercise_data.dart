// models/exercise_data.dart

class ExerciseData {
  final String id;
  final String exercise;
  final String variable;
  final num value;
  final DateTime timestamp;

  ExerciseData({
    required this.id,
    required this.exercise,
    required this.variable,
    required this.value,
    required this.timestamp,
  });

  // Factory constructor to create ExerciseData from Map
  factory ExerciseData.fromMap(Map<String, dynamic> map) {
    return ExerciseData(
      id: map['id'] as String,
      exercise: map['exercise'] as String,
      variable: map['variable'] as String,
      value: map['value'] as num,
      timestamp: map['timestamp'] as DateTime,
    );
  }

  // Convert ExerciseData to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'variable': variable,
      'value': value,
      'timestamp': timestamp,
    };
  }

  // Create a copy with modified fields
  ExerciseData copyWith({
    String? id,
    String? exercise,
    String? variable,
    num? value,
    DateTime? timestamp,
  }) {
    return ExerciseData(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      variable: variable ?? this.variable,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
