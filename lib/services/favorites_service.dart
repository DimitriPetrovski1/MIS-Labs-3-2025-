// lib/services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // If you add auth later, replace this with the actual uid.
  final String _userId = 'test-user';

  /// Add favorite (mealData should contain at least id, name, thumb)
  Future<void> addFavorite(String mealId, Map<String, dynamic> mealData) {
    final doc = _db
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(mealId);
    return doc.set(mealData);
  }

  /// Remove favorite
  Future<void> removeFavorite(String mealId) {
    final doc = _db
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(mealId);
    return doc.delete();
  }

  /// Toggle favorite: add if missing, remove if exists
  Future<void> toggleFavorite(String mealId, Map<String, dynamic> mealData) async {
    final doc = _db
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(mealId);

    final snap = await doc.get();
    if (snap.exists) {
      await doc.delete();
    } else {
      await doc.set(mealData);
    }
  }

  /// Stream whether a specific meal is favorite
  Stream<bool> isFavorite(String mealId) {
    final doc = _db
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(mealId);
    return doc.snapshots().map((s) => s.exists);
  }

  /// Stream of favorite documents data (list of maps)
  Stream<List<Map<String, dynamic>>> favoritesStream() {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      final m = d.data();
      // Ensure id is present
      if (!m.containsKey('id')) m['id'] = d.id;
      return m;
    }).toList());
  }
}