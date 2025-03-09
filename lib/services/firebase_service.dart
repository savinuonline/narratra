import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Example: "Trending" books are those with likeCount >= 3
  Future<List<Book>> getTrendingBooks() async {
    final querySnapshot = await _firestore
        .collection('books')
        .where('likeCount', isGreaterThanOrEqualTo: 3)
        .get();

    return querySnapshot.docs
        .map((doc) => Book.fromMap(doc.data()))
        .toList();
  }

  /// "Recommended" books based on user's selectedGenres
  Future<List<Book>> getRecommendedBooks(String uid) async {
    // 1) Fetch user doc
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data()!;
    final userGenres = List<String>.from(userData['selectedGenres'] ?? []);

    // 2) If no genres are selected, return empty list
    if (userGenres.isEmpty) return [];

    // 3) Query books whose 'genre' is in userGenres (up to 10 genres allowed)
    final querySnapshot = await _firestore
        .collection('books')
        .where('genre', whereIn: userGenres.take(10).toList())
        .get();

    return querySnapshot.docs
        .map((doc) => Book.fromMap(doc.data()))
        .toList();
  }

  /// "Today For You" logic: fetch all books, then return 5 random ones.
  Future<List<Book>> getTodayForYouBooks() async {
    final allDocs = await _firestore.collection('books').get();
    final allBooks = allDocs.docs.map((doc) => Book.fromMap(doc.data())).toList();

    if (allBooks.isEmpty) return [];

    allBooks.shuffle();
    return allBooks.take(5).toList();
  }

  /// "Free" books are those with isFree = true
  Future<List<Book>> getFreeBooks() async {
    final querySnapshot = await _firestore
        .collection('books')
        .where('isFree', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Book.fromMap(doc.data()))
        .toList();
  }

  /// Update user’s selected genres in Firestore
  Future<void> updateUserGenres(String uid, List<String> genres) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'selectedGenres': genres,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
