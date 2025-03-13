import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// You can store a static list of category doc IDs. Make sure these match exactly
  /// the doc names in your Firestore under the top-level "books" collection.
  final List<String> categories = [
    "Children's literature",
    "Horror",
    "Fantasy",
    "Romance",
    "Thriller",
    "Adventure",
  ];

  /// Example: "Trending" books are those with likeCount >= 3
  /// We loop each category doc => subcollection("books").where('likeCount' >= 3).
  Future<List<Book>> getTrendingBooks() async {
    final List<Book> trending = [];

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      // Query docs where likeCount >= 3
      final querySnapshot = await subcollectionRef
          .where('likeCount', isGreaterThanOrEqualTo: 3)
          .get();

      final catBooks = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();
      trending.addAll(catBooks);
    }

    return trending;
  }

  /// "Recommended" books based on user's selectedGenres
  /// Each user genre corresponds to a doc ID in the top-level "books" collection.
  Future<List<Book>> getRecommendedBooks(String uid) async {
    // 1) Fetch user doc
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data()!;
    final userGenres = List<String>.from(userData['selectedGenres'] ?? []);

    // 2) If no genres are selected, return empty list
    if (userGenres.isEmpty) return [];

    // 3) For each genre, go to doc(genre).collection("books") and fetch everything
    final List<Book> recommended = [];

    for (final genre in userGenres) {
      // If your doc ID literally matches the genre name, do:
      final subcollectionRef = _firestore
          .collection('books')
          .doc(genre)
          .collection('books');

      final querySnapshot = await subcollectionRef.get();
      final genreBooks = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();
      recommended.addAll(genreBooks);
    }

    return recommended;
  }

  /// "Today For You" logic: fetch *all* categories, gather all books, shuffle, return 5.
  Future<List<Book>> getTodayForYouBooks() async {
    final List<Book> allBooks = [];

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      final querySnapshot = await subcollectionRef.get();
      final catBooks = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();
      allBooks.addAll(catBooks);
    }

    if (allBooks.isEmpty) return [];

    allBooks.shuffle();
    return allBooks.take(5).toList();
  }

  /// "Free" books are those with isFree = true. We fetch from each category doc => subcollection
  Future<List<Book>> getFreeBooks() async {
    final List<Book> free = [];

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      // Query isFree == true
      final querySnapshot = await subcollectionRef
          .where('isFree', isEqualTo: true)
          .get();

      final catBooks = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();
      free.addAll(catBooks);
    }

    return free;
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
