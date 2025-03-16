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
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      final querySnapshot =
          await subcollectionRef
              .where('likeCount', isGreaterThanOrEqualTo: 3)
              .get();

      final catBooks =
          querySnapshot.docs
              .map((doc) => Book.fromMap({...doc.data(), 'genre': cat}, doc.id))
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
      final genreBooks =
          querySnapshot.docs
              .map(
                (doc) => Book.fromMap({...doc.data(), 'genre': genre}, doc.id),
              )
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
      final catBooks =
          querySnapshot.docs
              .map((doc) => Book.fromMap({...doc.data(), 'genre': cat}, doc.id))
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

      // Query isFree == true
      final querySnapshot =
          await subcollectionRef.where('isFree', isEqualTo: true).get();

      final catBooks =
          querySnapshot.docs
              .map((doc) => Book.fromMap({...doc.data(), 'genre': cat}, doc.id))
              .toList();
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

  /// Get book by ID with author details
  Future<Book?> getBookById(String bookId) async {
    try {
      print('Fetching book with ID: $bookId');

      // Search through all genre collections
      for (final genre in categories) {
        print('Checking genre: $genre');

        final bookDoc =
            await _firestore
                .collection('books')
                .doc(genre)
                .collection('books')
                .doc(bookId)
                .get();

        if (bookDoc.exists) {
          print('Found book in genre: $genre');
          final bookData = bookDoc.data()!;

          // Get author details
          final authorDetails = await getAuthorByName(bookData['author'] ?? '');

          // Merge book data with genre and author details
          final mergedData = {
            ...bookData,
            'genre': genre,
            'authorDescription':
                authorDetails?['description'] ??
                'No author description available.',
            'authorImageUrl': authorDetails?['imageUrl'] ?? '',
          };

          return Book.fromMap(mergedData, bookId);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the next available sequential ID
  Future<String> _getNextBookId() async {
    int highestId = 0;

    // Check all categories for the highest ID
    for (final genre in categories) {
      final snapshot =
          await _firestore
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
        throw ArgumentError(
          'Invalid genre: $genre. Must be one of: $categories',
        );
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

  /// Get a stream of liked books for a user
  Stream<List<Book>> getLikedBooksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_books')
        .snapshots()
        .asyncMap((snapshot) async {
          List<Book> likedBooks = [];

          for (var doc in snapshot.docs) {
            final bookId = doc.id;
            final book = await getBookById(bookId);
            if (book != null) {
              likedBooks.add(book);
            }
          }

          return likedBooks;
        });
  }

  /// Check if a book is liked by the user
  Future<bool> isBookLiked(String userId, String bookId) async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('liked_books')
            .doc(bookId)
            .get();

    return doc.exists;
  }

  /// Toggle like status for a book
  Future<bool> toggleBookLike(String userId, String bookId) async {
    final likedBooksRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_books')
        .doc(bookId);

    final doc = await likedBooksRef.get();

    if (doc.exists) {
      // Unlike the book
      await likedBooksRef.delete();
      return false;
    } else {
      // Like the book
      await likedBooksRef.set({'timestamp': FieldValue.serverTimestamp()});
      return true;
    }
  }

  // Get a stream of saved audiobooks for a user
  Stream<List<Book>> getSavedAudiobooksStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_audiobooks')
        .snapshots()
        .asyncMap((snapshot) async {
          List<Book> books = [];
          for (var doc in snapshot.docs) {
            String bookId = doc.id;
            Book? book = await getBookById(bookId);
            if (book != null) {
              books.add(book);
            }
          }
          return books;
        });
  }

  // Check if an audiobook is saved by the user
  Future<bool> isAudiobookSaved(String userId, String bookId) async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('saved_audiobooks')
            .doc(bookId)
            .get();
    return doc.exists;
  }

  // Toggle save status of an audiobook
  Future<void> toggleAudiobookSave(String userId, String bookId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_audiobooks')
        .doc(bookId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({'savedAt': DateTime.now()});
    }
  }

  // Save listening progress for an audiobook
  Future<void> saveListeningProgress(
    String userId,
    String bookId,
    Duration position,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('listening_progress')
        .doc(bookId)
        .set({'position': position.inSeconds, 'updatedAt': DateTime.now()});
  }

  // Get listening progress for an audiobook
  Future<Duration?> getListeningProgress(String userId, String bookId) async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('listening_progress')
            .doc(bookId)
            .get();

    if (doc.exists && doc.data()?['position'] != null) {
      return Duration(seconds: doc.data()!['position']);
    }
    return null;
  }

  // Get listening history for a user
  Stream<List<Book>> getListeningHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('listening_progress')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Book> books = [];
          for (var doc in snapshot.docs) {
            String bookId = doc.id;
            Book? book = await getBookById(bookId);
            if (book != null) {
              books.add(book);
            }
          }
          return books;
        });
  }

  /// Get author details by name - needed for book details
  Future<Map<String, dynamic>?> getAuthorByName(String name) async {
    try {
      final doc = await _firestore.collection('authors').doc(name).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting author: $e');
      return null;
    }
  }

  /// Get a stream of all authors
  Stream<List<Map<String, dynamic>>> getAuthorsStream() {
    return _firestore
        .collection('authors')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );
  }

  Future<bool> isBookBookmarked(String userId, String bookId) async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('bookmarks')
            .doc(bookId)
            .get();
    return doc.exists;
  }

  Future<bool> createPlaylist(
    String userId,
    String playlistName,
    String bookId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .add({
            'name': playlistName,
            'books': [bookId],
            'createdAt': DateTime.now(),
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> incrementBookLikeCount(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final likeCount = data['likeCount'] ?? 0;
      // Increment the book's like count by 1
    }
  }

  Future<void> decrementBookLikeCount(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final likeCount = data['likeCount'] ?? 0;
    }
  }
}
