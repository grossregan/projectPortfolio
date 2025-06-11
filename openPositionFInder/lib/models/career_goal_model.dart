class CareerGoal {
  String text; // The description of the career goal
  String type; // Either "Short Term" or "Long Term"
  bool completed; // Whether the goal is completed

  CareerGoal({
    required this.text,
    required this.type,
    this.completed = false,
  });

  // Factory method to create a CareerGoal from a map
  factory CareerGoal.fromMap(Map<String, dynamic> map) {
    return CareerGoal(
      text: map['text'],
      type: map['type'],
      completed: map['completed'] ?? false,
    );
  }

  // Convert a CareerGoal to a map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'type': type,
      'completed': completed,
    };
  }
}
