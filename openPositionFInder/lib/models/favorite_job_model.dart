import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_3541_final_project/models/interview_resource_model.dart';
import 'package:cs_3541_final_project/models/job_information_model.dart';

class FavoriteJobModel {
  static final CollectionReference _favoriteJobsReference =
      FirebaseFirestore.instance.collection('jobFavorites');

  static Future<Map<String, JobData>> getFavorites() async {
    final snapshot = await _favoriteJobsReference.get();
    // snapshot.docs.forEach((doc) => _favoriteJobsReference.doc(doc.id).delete());
    return Map.fromEntries(snapshot.docs.map((doc) =>
        MapEntry(doc.id, JobData.fromMap(doc.data() as Map<String, dynamic>))));
  }

  static Future<void> removeFavorite(final String id) async {
    await _favoriteJobsReference.doc(id).delete();
  }

  static Future<void> addFavorite(final JobData job) async {
    await _favoriteJobsReference.doc(job.jobId).set(job.toMap());
  }
}

class FavoriteResourceModel extends ResourceData {
  final String id;

  static final CollectionReference _favoriteResourceReference =
      FirebaseFirestore.instance.collection('resourceFavorites');

  FavoriteResourceModel(
      {required this.id,
      required super.url,
      required super.resourceName,
      required super.imagePath});

  factory FavoriteResourceModel.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return FavoriteResourceModel(
        id: docId,
        url: data["url"],
        resourceName: data["resourceName"],
        imagePath: data["imagePath"]);
  }

  static Future<List<FavoriteResourceModel>> getFavorites() async {
    final snapshot = await _favoriteResourceReference.get();
    return snapshot.docs.map((doc) {
      return FavoriteResourceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  static Future<void> removeFavorite(id) async {
    await _favoriteResourceReference.doc(id).delete();
  }

  static Future<void> addFavorite(FavoriteResourceModel resource) async {
    await _favoriteResourceReference.doc(resource.id).set(resource.toMap());
  }
}
