import 'dart:convert';
import 'dart:core';

import 'package:agile_avengers_get_fit/models/favorite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:parse_json/parse_json.dart';

final logger = Logger();

class FirestoreInstructions {
  //adapted from suggestions by Claude.ai, April 2025
  final CollectionReference favoriteCollection = FirebaseFirestore.instance
      .collection('favorites');

  Future<void> addExercise(InitExercise exercise) async {
    try {
      await favoriteCollection.add(exercise.toMap());
    } catch (e) {
      logger.e('Error adding exercise: $e');
    }
  }

  Future<void> removeExercise(InitExercise exercise) async {
    try {
      List<FavoriteModel> favorites = await FavoriteModel.getFavorites();
      for (FavoriteModel favorite in favorites) {
        if (favorite.name == exercise.name) {
          FavoriteModel.removeFavorite(favorite.id, favorite.name);
        }
      }
    } catch (e) {
      logger.e('Error deleting exercise: $e');
    }
  }
}

class ExerciseModel {
  FirestoreInstructions exerciseService = FirestoreInstructions();
  String apiKey = 'rsRhdewcBXOgq91I+BAdCA==M904FDjuiwCr1TEX';

  List<Map<String, dynamic>> formatMuscleGroups() {
    List<String> muscles = [
      'biceps',
      'glutes',
      'quadriceps',
      'calves',
      'forearms',
    ];
    List<Map<String, dynamic>> groupCodes = [];

    for (String muscle in muscles) {
      groupCodes.add({'type': 'strength', 'muscle': muscle, 'lang': 'dart'});
    }

    return groupCodes;
  }

  Future<List<InitExercise>> fetchExercises() async {
    List<Map<String, dynamic>> formattedGroups = formatMuscleGroups();
    List<InitExercise> finishedData = [];

    for (var muscleGroup in formattedGroups) {
      final url = Uri.http('api.api-ninjas.com', '/v1/exercises', muscleGroup);
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        finishedData.addAll(
          data.map((json) => InitExercise.fromJson(json)).toList(),
        );
      }
    }
    if (finishedData.isNotEmpty) {
      return finishedData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<InitExercise> getHardCodedExercises() {
    //Adapted from suggestions by Claude.ai, April 2025
    return [
      InitExercise(name: 'Push Up', type: 'strength', muscle: 'chest'),
      InitExercise(name: 'Pull Up', type: 'strength', muscle: 'back'),
      InitExercise(name: 'Bench Press', type: 'strength', muscle: 'chest'),
    ];
  }
}

class InitExercise {
  final String name;
  final String type;
  final String muscle;
  final String? equipment;
  final String? difficulty;
  final String? instructions;
  final String? id;

  const InitExercise({
    required this.name,
    required this.type,
    required this.muscle,
    this.instructions,
    this.difficulty,
    this.equipment,
    this.id,
  });

  factory InitExercise.fromJson(dynamic json) => parse(InitExercise.new, json, {
    'name': string,
    'type': string,
    'muscle': string,
    'instructions': string,
    'difficulty': string,
    'equipment': string,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'muscle': muscle,
      'instructions': instructions ?? '',
      'difficulty': difficulty ?? '',
      'equipment': equipment ?? '',
      'id': id,
    };
  }
}
