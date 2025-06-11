import 'package:cs_3541_final_project/models/career_goal_model.dart';

class CareerGoalsPresenter {
  final List<CareerGoal> _careerGoals = [];

  List<CareerGoal> getCareerGoals() {
    return _careerGoals;
  }

  void addCareerGoal(String text, String type) {
    _careerGoals.add(CareerGoal(text: text, type: type));
  }

  void toggleGoalCompletion(int index) {
    _careerGoals[index].completed = !_careerGoals[index].completed;
  }
}
