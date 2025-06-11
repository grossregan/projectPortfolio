import 'dart:convert';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class FirestoreInstructions {
  final CollectionReference favoriteReference =
      FirebaseFirestore.instance.collection('resourceFavorites');

  Future<void> addFavorite(ResourceData resource) async {
    await favoriteReference.add(resource.toMap());
  }

  Future<void> deleteFavorite(ResourceData resource) async {
    List<FavoriteResourceModel> favorites =
        await FavoriteResourceModel.getFavorites();
    try {
      for (var favorite in favorites) {
        if (resource.resourceName == favorite.resourceName) {
          FavoriteResourceModel.removeFavorite(favorite.id);
        }
      }
    } catch (e) {
      print('Error deleting resource: $e');
    }
  }
}

class ResourceModel {
  Future<List<ResourceData>> fetchResources() async {
    final resources =
        await rootBundle.loadString('assets/data/interview_resources.json');

    final List<dynamic> resourceList = json.decode(resources);
    return resourceList.map((json) => ResourceData.fromJson(json)).toList();
  }
}

class ResourceData {
  final String url;
  final String resourceName;
  final String imagePath;

  const ResourceData(
      {required this.url, required this.resourceName, required this.imagePath});

  factory ResourceData.fromJson(Map<String, dynamic> json) {
    return ResourceData(
        url: json["url"],
        resourceName: json["resourceName"],
        imagePath: json["imagePath"]);
  }

  Map<String, dynamic> toMap() {
    return {'url': url, 'resourceName': resourceName, 'imagePath': imagePath};
  }
}
