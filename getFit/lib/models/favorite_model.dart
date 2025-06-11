import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String name;
  final String description;

  FavoriteModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory FavoriteModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoriteModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    ); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description':
          description, // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
    };
  }

  static final CollectionReference _Favoritecollection = FirebaseFirestore
      .instance
      .collection('favorites');

  static Future<List<FavoriteModel>> getFavorites() async {
    final snapshot = await _Favoritecollection.get();
    return snapshot.docs.map((doc) {
      return FavoriteModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
    }).toList();
  }

  static Future<void> removeFavorite(id, name) async {
    await _Favoritecollection.doc(id).delete();
  }

  static Future<void> addFavorite(FavoriteModel favorite) async {
    await _Favoritecollection.doc(favorite.id).set(
      favorite.toMap(),
    ); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
  }

  static Future<void> editFavoriteDescription(
    String id,
    String newDescription,
  ) async {
    //need to work on this
    await _Favoritecollection.doc(id).update({'description': newDescription});
  }
}
