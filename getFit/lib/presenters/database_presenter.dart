// presenters/database_presenter.dart

import 'package:agile_avengers_get_fit/models/exercise_data.dart';
import 'package:agile_avengers_get_fit/utils/sample_data_generator.dart';
import 'package:agile_avengers_get_fit/views/database_contract.dart';

class DatabasePresenter implements DatabasePresenterContract {
  final DatabaseViewContract _view;
  List<ExerciseData> _allData = [];
  List<ExerciseData> _filteredData = [];
  List<String> _exercises = [];
  List<String> _variables = [];

  String? _selectedExercise;
  String? _selectedVariable;
  bool _ascending = true;

  DatabasePresenter(this._view);

  @override
  Future<void> loadData() async {
    _view.showLoading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Load sample data
      _allData = SampleDataGenerator.generateExerciseData();

      // Extract unique exercises and variables
      final Set<String> exerciseSet = {};
      final Set<String> variableSet = {};

      for (var item in _allData) {
        exerciseSet.add(item.exercise);
        variableSet.add(item.variable);
      }

      _exercises = exerciseSet.toList()..sort();
      _variables = variableSet.toList()..sort();

      // Initial filter
      _applyFilters();
      _view.hideLoading();
    } catch (e) {
      _view.hideLoading();
      _view.showError('Failed to load data: $e');
    }
  }

  @override
  void filterData(
    String? selectedExercise,
    String? selectedVariable,
    bool ascending,
  ) {
    _selectedExercise = selectedExercise;
    _selectedVariable = selectedVariable;
    _ascending = ascending;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredData =
        _allData.where((item) {
          final matchesExercise =
              _selectedExercise == null || item.exercise == _selectedExercise;
          final matchesVariable =
              _selectedVariable == null || item.variable == _selectedVariable;
          return matchesExercise && matchesVariable;
        }).toList();

    if (_selectedVariable != null) {
      _filteredData.sort((a, b) {
        return _ascending
            ? a.value.compareTo(b.value)
            : b.value.compareTo(a.value);
      });
    }

    _view.updateData(_filteredData, _exercises, _variables);
  }

  @override
  List<ExerciseData> getFilteredData() {
    return _filteredData;
  }

  @override
  String getGraphTitle(String? selectedExercise, String? selectedVariable) {
    String title = 'Data Overview';

    if (selectedExercise != null) {
      title = selectedExercise;
    }

    if (selectedVariable != null) {
      title +=
          selectedExercise != null ? ' - $selectedVariable' : selectedVariable;
    }

    return title;
  }
}
