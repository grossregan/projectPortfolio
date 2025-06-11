// views/database_contract.dart
import 'package:agile_avengers_get_fit/models/exercise_data.dart';

// Define the contract between View and Presenter
abstract class DatabaseViewContract {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void updateData(
    List<ExerciseData> filteredData,
    List<String> exercises,
    List<String> variables,
  );
  void refreshView();
}

abstract class DatabasePresenterContract {
  void loadData();
  void filterData(
    String? selectedExercise,
    String? selectedVariable,
    bool ascending,
  );
  List<ExerciseData> getFilteredData();
  String getGraphTitle(String? selectedExercise, String? selectedVariable);
}
