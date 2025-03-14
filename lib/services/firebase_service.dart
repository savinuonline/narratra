import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update this list so it matches exactly the doc names
  /// you have under the top-level "books" collection in Firestore.
  /// For example, if your Firestore shows doc IDs:
  ///   "Children's literature", "Fiction", "Romance", "Thriller"
  /// then use exactly those strings here.
  final List<String> categories = [
    "Children's literature",
    "Fiction",
    "Romance",
    "Thriller",
    // Add or remove any others as needed
  ];

  /// "Trending" books: docs with likeCount >= 3 in each subcollection.
  Future<List<Book>> getTrendingBooks() async {
    final List<Book> trending = [];

    for (final cat in categories) {
      // e.g. books -> doc("Children's literature") -> collection("books")
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

  /// "Recommended" books: based on user's selectedGenres.
  /// Each user genre should match one of the doc IDs in `categories`.
  Future<List<Book>> getRecommendedBooks(String uid) async {
    // 1) Fetch user doc
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return [];

    final userData = userDoc.data()!;
    final userGenres = List<String>.from(userData['selectedGenres'] ?? []);

    // 2) If no genres selected, return empty
    if (userGenres.isEmpty) return [];

    final List<Book> recommended = [];

    // 3) For each genre, load all books from that doc's subcollection
    for (final genre in userGenres) {
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

  /// "Today For You": gather *all* books from all categories, shuffle, pick 5.
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

  /// "Free" books: docs with isFree == true in each subcollection.
  Future<List<Book>> getFreeBooks() async {
    final List<Book> free = [];

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      // Query for isFree == true
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
