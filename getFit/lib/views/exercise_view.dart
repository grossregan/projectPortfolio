import 'package:agile_avengers_get_fit/models/favorite_model.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/favorite_view.dart';
import 'package:flutter/material.dart';

import '../presenters/exercise_presenter.dart';
import '../models/exercise_model.dart';

Set<String> currentFavorites = {};

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ExerciseItem());
  }
}

class ExerciseItem extends StatefulWidget {
  const ExerciseItem({super.key});

  @override
  State<ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<ExerciseItem> {
  late ExercisePresenter _presenter;
  List<InitExercise> _exercises = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = ExercisePresenter(
      ExerciseModel(),
      (exercises) => setState(() => _exercises = exercises),
      (isLoading) => setState(() => _isLoading = isLoading),
      (error) => setState(() => _errorMessage = error),
    );
    _exercises.insert(
      0,
      InitExercise(name: 'DUMMY', type: 'strength', muscle: 'biceps'),
    );
    _presenter.loadExercises();
    _getFavorites();
  }

  void _getFavorites() {
    FavoriteModel.getFavorites().then((favorites) {
      setState(() {
        currentFavorites = favorites.map((element) => element.name).toSet();
      });
    });
  }

  void favorited(InitExercise exercise) {
    setState(() {
      if (currentFavorites.contains(exercise.name)) {
        currentFavorites.remove(exercise.name);
        _presenter.removeFavorite(exercise);
      } else {
        currentFavorites.add(exercise.name);
        _presenter.addFavorite(exercise);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Exercise Page',
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteView()),
                ),
          ),
        ],
      ),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fitness-backround.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(),
          ),
          Column(
            children: <Widget>[
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    padding: const EdgeInsets.all(10.0),
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  color: Colors.amber,
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Text(_errorMessage!, textAlign: TextAlign.center),
                ),

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(8),
                  itemCount: _exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    final exercise = _exercises[index];
                    final isFavorited = currentFavorites.contains(
                      exercise.name,
                    );

                    if (index == 0) {
                      return SizedBox(
                        child: Card(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: .90),
                          child: Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                            _exercises[0].muscle.toUpperCase(),
                          ),
                        ),
                      );
                    }

                    return Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: .90),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited ? Colors.red : null,
                          ),
                          onPressed: () => favorited(exercise),
                        ),
                        title: Text(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          exercise.name,
                        ),
                        subtitle: Text(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          '${exercise.difficulty} | ${exercise.muscle}',
                        ),
                        onTap: () => {showMoreInfo(exercise)},
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    if (_exercises[index].muscle !=
                        _exercises[index + 1].muscle) {
                      Divider();
                      return SizedBox(
                        child: Card(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: .90),
                          child: Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                            ),
                            _exercises[index + 1].muscle.toUpperCase(),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showMoreInfo(InitExercise exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                '${exercise.instructions}',
              ),
            ),
          ),
        );
      },
    );
  }
}
