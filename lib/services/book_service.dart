import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> categories = [
    "Children's literature",
    "Horror",
    "Fantasy",
    "Fiction",
    "Romance",
    "Thriller",
    "Adventure",
  ];

  /// Find the first available ID by checking for gaps in the sequence
  Future<String> _getNextAvailableId() async {
    // Get all existing IDs across all categories
    Set<int> existingIds = {};

    for (final genre in categories) {
      final snapshot = await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .get();

      for (final doc in snapshot.docs) {
        final id = int.tryParse(doc.id) ?? 0;
        existingIds.add(id);
      }
    }

    if (existingIds.isEmpty) {
      return '001'; // First book
    }

    // Find the first gap in the sequence
    int nextId = 1;
    while (existingIds.contains(nextId)) {
      nextId++;
    }

    // Format with leading zeros
    return nextId.toString().padLeft(3, '0');
  }

  /// Add a new book with the next available ID
  Future<String> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String imageUrl,
    required String audioUrl,
    bool isFree = false,
  }) async {
    try {
      if (!categories.contains(genre)) {
        throw ArgumentError('Invalid genre: $genre');
      }

      final String nextId = await _getNextAvailableId();
      print('Adding book with ID: $nextId'); // Debug print

      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'isFree': isFree,
        'likeCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(nextId)
          .set(bookData);

      print('Book added successfully with ID: $nextId'); // Debug print
      return nextId;
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Get all books across all genres as a Stream
  Stream<List<Map<String, dynamic>>> getAllBooksStream() {
    print('Starting to listen to books stream'); // Debug print

    // Create a stream for each category
    final streams = categories.map((genre) {
      return _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print('Received update for genre: $genre'); // Debug print
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'genre': genre,
            ...doc.data(),
          };
        }).toList();
      });
    }).toList();
    // Combine all streams into one
    return Rx.combineLatestList(streams)
        .map((List<List<Map<String, dynamic>>> lists) {
      final allBooks = lists.expand((list) => list).toList();
      allBooks.sort((a, b) {
        final aTime =
            (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime =
            (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime); // Sort by creation time, newest first
      });
      print('Total books in stream: ${allBooks.length}'); // Debug print
      return allBooks;
    });
  }

  /// Delete a book by ID and genre
  Future<void> deleteBook(String id, String genre) async {
    try {
      print('Deleting book with ID: $id from genre: $genre'); // Debug print
      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(id)
          .delete();
      print('Book deleted successfully'); // Debug print
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  /// Update an existing book
  Future<void> updateBook({
    required String id,
    required String genre,
    required String title,
    required String author,
    required String description,
    required String imageUrl,
    required String audioUrl,
    bool isFree = false,
  }) async {
    try {
      if (!categories.contains(genre)) {
        throw ArgumentError('Invalid genre: $genre');
      }

      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'isFree': isFree,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(id)
          .update(bookData);

      print('Book updated successfully with ID: $id');
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }
}
