import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class InspirationModel {
  static final favoriteInspirations = FirebaseFirestore.instance.collection(
    'favorite-inspirations',
  );

  static String toId(String url) {
    return url.split('/').last.split('.').first;
  }

  static String toUrl(String id) {
    return 'https://generated.inspirobot.me/a/$id.png';
  }

  static Future<String> getInspiration({String? id}) async {
    if (id == null) {
      return await http
          .get(Uri.parse('https://inspirobot.me/api?generate=true'))
          .then((r) => r.body);
    } else {
      return favoriteInspirations
          .doc(id)
          .get()
          .then(
            (DocumentSnapshot doc) => doc['url'],
            onError: (e) => throw Exception('Failed to load inspiration: $e'),
          );
    }
  }

  static Future<Map<String, DateTime>> getFavorites() async {
    final docs = await favoriteInspirations.get().then((snap) => snap.docs);
    docs.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
    return {
      for (final doc in docs)
        doc['url']: (doc['createdAt'] as Timestamp).toDate(),
    };
  }

  static Future<void> addFavorite(String url, {DateTime? addedAt}) async {
    await favoriteInspirations.doc(toId(url)).set({
      'url': url,
      'createdAt': addedAt ?? DateTime.now(),
    });
  }

  /// In theory, this actually works with URLs as well due to toId().
  /// Returns the time the inspiration was created
  static Future<DateTime> removeFavorite(String url) async {
    final insp = await favoriteInspirations.doc(toId(url)).get();
    if (!insp.exists) {
      logger.e('Inspiration not found');
      return DateTime.now();
    }
    await favoriteInspirations.doc(toId(url)).delete();
    final data = insp.data() as Map<String, dynamic>;
    return (data['createdAt'] as Timestamp).toDate();
  }
}
