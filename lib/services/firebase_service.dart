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
      final genreBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': genre})
      ).toList();
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
      final catBooks = querySnapshot.docs.map((doc) => 
        Book.fromMap({...doc.data(), 'id': doc.id, 'genre': cat})
      ).toList();
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

      // Try each genre collection
      for (final genre in categories) {
        print('\nChecking in genre: $genre');
        final bookRef = _firestore
            .collection('books')
            .doc(genre)
            .collection('books')
            .doc(bookId);

        final bookDoc = await bookRef.get();
        print('Book exists in $genre: ${bookDoc.exists}');
        
        if (bookDoc.exists) {
          final data = bookDoc.data()!;
          print('Found book data: $data');
          
          // Create book with the correct genre
          final book = Book.fromMap({
            ...data,
            'id': bookId,
            'genre': genre, // Use the current genre
          });
          print('Successfully created book object: ${book.title} by ${book.author} in genre: ${book.genre}');
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

  /// Get the next available sequential ID
  Future<String> _getNextBookId() async {
    int highestId = 0;

    // Check all categories for the highest ID
    for (final genre in categories) {
      final snapshot = await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .get();

      for (final doc in snapshot.docs) {
        // Parse the numeric ID
        final currentId = int.tryParse(doc.id) ?? 0;
        if (currentId > highestId) {
          highestId = currentId;
        }
      }
    }

    // Format the next ID with leading zeros
    return (highestId + 1).toString().padLeft(3, '0');
  }

  /// Add a new book to Firestore with a sequential ID
  Future<String> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String imageUrl,
    required String audioUrl,
    bool isFree = false,
    int likeCount = 0,
  }) async {
    try {
      // Validate that the genre exists
      if (!categories.contains(genre)) {
        throw ArgumentError('Invalid genre: $genre. Must be one of: $categories');
      }

      // Get the next available ID
      final String nextId = await _getNextBookId();

      // Create the book data
      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'genre': genre,
        'isFree': isFree,
        'likeCount': likeCount,
      };

      // Add to Firestore with sequential ID
      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(nextId)
          .set(bookData);

      print('Added book "${title}" with ID: $nextId in genre: $genre');
      return nextId;
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Migrate existing books to have unique IDs
  Future<void> migrateExistingBooks() async {
    try {
      print('Starting book migration...');

      for (final genre in categories) {
        print('\nMigrating books in genre: $genre');
        
        // Get all books in this genre
        final booksRef = _firestore
            .collection('books')
            .doc(genre)
            .collection('books');
            
        final snapshot = await booksRef.get();

        // Process each book
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final oldId = doc.id;

          // Skip if this isn't one of the duplicate '001' IDs
          if (oldId != '001') {
            print('Skipping book with unique ID: $oldId');
            continue;
          }

          print('Migrating book: ${data['title']}');

          // Add new document with auto-generated ID
          final newDoc = await booksRef.add(data);
          print('Created new document with ID: ${newDoc.id}');

          // Delete the old document
          await doc.reference.delete();
          print('Deleted old document with ID: $oldId');
        }
      }

      print('\nMigration completed successfully!');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    }
  }
}
