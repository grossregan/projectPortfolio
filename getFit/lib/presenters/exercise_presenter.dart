import 'package:agile_avengers_get_fit/models/exercise_model.dart';
import 'package:agile_avengers_get_fit/models/favorite_model.dart';

//class stores exercises and stores add and remove methods for list
class ExercisePresenter {
  final ExerciseModel _exerciseModel;
  List<InitExercise> _exercises = [];
  // ignore: unused_field
  List<FavoriteModel> _favorites = [];
  final Function(List<InitExercise>) _updateUI;
  final Function(bool) _setLoading;
  final Function(String) _showError;
  final firebaseService = FirestoreInstructions();

  ExercisePresenter(
    this._exerciseModel,
    this._updateUI,
    this._setLoading,
    this._showError,
  );

  List<InitExercise> getExercises() {
    return _exercises;
  }

  Future<void> loadExercises() async {
    _setLoading(true);
    try {
      _exercises = await _exerciseModel.fetchExercises();
      _favorites = await FavoriteModel.getFavorites();

      _updateUI(_exercises);
    } catch (e) {
      _showError('Error loading exercises: $e');
      _exercises = _exerciseModel.getHardCodedExercises();

      _updateUI(_exercises);
    } finally {
      _setLoading(false);
    }
  }

  void addFavorite(InitExercise exercise) {
    firebaseService.addExercise(exercise);
  }

  void removeFavorite(InitExercise exercise) {
    firebaseService.removeExercise(exercise);
  }
}
