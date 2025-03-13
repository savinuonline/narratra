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

      final catBooks =
          querySnapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
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
      final genreBooks =
          querySnapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
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
      final catBooks =
          querySnapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
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

      final catBooks =
          querySnapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
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

  Future<Book?> getBookById(String bookId) async {
    try {
      print('Searching for book with ID: $bookId');

      // First try: direct path if we know the genre
      final genresSnapshot =
          await FirebaseFirestore.instance.collection('books').get();

      for (var genre in genresSnapshot.docs) {
        final bookDoc =
            await FirebaseFirestore.instance
                .collection('books')
                .doc(genre.id)
                .collection('books')
                .doc(bookId)
                .get();

        if (bookDoc.exists) {
          print('Found book in genre: ${genre.id}');
          return Book.fromMap(bookDoc.data()!);
        }
      }

      // Second try: collection group query (requires index)
      final querySnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('books')
              .where('id', isEqualTo: bookId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Found book using collection group query');
        return Book.fromMap(querySnapshot.docs.first.data());
      }

      print('Book not found');
      return null;
    } catch (e) {
      print('Error in getBookById: $e');
      return null;
    }
  }

  Future<void> setupTestData() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Sample genres and their books
    final Map<String, List<Map<String, dynamic>>> booksData = {
      'Children\'s literature': [
        {
          'id': '001',
          'title': 'The Little Prince',
          'author': 'Antoine de Saint-Exupéry',
          'description':
              'A poetic tale about a pilot stranded in the desert...',
          'imageUrl': 'https://example.com/little-prince.jpg',
          'audioUrl': 'https://example.com/little-prince.mp3',
          'genre': 'Children\'s literature',
        },
      ],
      'Fiction': [
        {
          'id': '002',
          'title': 'The Hobbit',
          'author': 'J.R.R. Tolkien',
          'description': 'Bilbo Baggins\' unexpected journey...',
          'imageUrl': 'https://example.com/hobbit.jpg',
          'audioUrl': 'https://example.com/hobbit.mp3',
          'genre': 'Fiction',
        },
      ],
    };

    // Create the structure
    for (var genre in booksData.entries) {
      final genreRef = db.collection('books').doc(genre.key);

      // Create books subcollection
      final booksCollection = genreRef.collection('books');

      // Add books to the subcollection
      for (var bookData in genre.value) {
        await booksCollection.doc(bookData['id']).set(bookData);
        print('Added book ${bookData['id']} to ${genre.key}');
      }
    }

    print('Test data setup complete!');
  }
}
