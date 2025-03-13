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
      final querySnapshot =
          await subcollectionRef
              .where('likeCount', isGreaterThanOrEqualTo: 3)
              .get();

      final catBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': cat})
      ).toList();
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
      final genreBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': genre})
      ).toList();
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
      final catBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': cat})
      ).toList();
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
      final querySnapshot =
          await subcollectionRef.where('isFree', isEqualTo: true).get();

      final catBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': cat})
      ).toList();
      free.addAll(catBooks);
    }

    return free;
  }

  /// Update user's selected genres in Firestore
  Future<void> updateUserGenres(String uid, List<String> genres) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'selectedGenres': genres,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      print('======= BOOK LOOKUP DEBUG =======');
      print('Searching for book with ID: $bookId');
      print('Using categories: $categories');

      // First, try to find the book in any genre to get its original genre
      String? originalGenre;
      for (final genre in categories) {
        final bookRef = _firestore
            .collection('books')
            .doc(genre)
            .collection('books')
            .doc(bookId);

        final bookDoc = await bookRef.get();
        if (bookDoc.exists) {
          final data = bookDoc.data()!;
          originalGenre = data['genre'] as String?;
          print('Found book in genre: $originalGenre');
          break;
        }
      }

      // If we found the book's original genre, look it up there
      if (originalGenre != null) {
        final bookRef = _firestore
            .collection('books')
            .doc(originalGenre)
            .collection('books')
            .doc(bookId);

        print('Looking up book in original genre: $originalGenre');
        final bookDoc = await bookRef.get();

        if (bookDoc.exists) {
          final data = bookDoc.data()!;
          print('Book data: $data');
          
          final book = Book.fromMap({
            ...data,
            'id': bookId,
            'genre': originalGenre,
          });
          print('Created book object: ${book.title} by ${book.author}');
          return book;
        }
      }

      print('\nBook $bookId not found in any genre');
      print('======= END DEBUG =======');
      return null;
    } catch (e) {
      print('Error in getBookById: $e');
      print('======= END DEBUG =======');
      return null;
    }
  }
}
