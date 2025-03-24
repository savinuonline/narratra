import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    Set<int> existingIds = {};

    for (final genre in categories) {
      final snapshot =
          await _firestore
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
      return '001';
    }

    int nextId = 1;
    while (existingIds.contains(nextId)) {
      nextId++;
    }

    return nextId.toString().padLeft(3, '0');
  }

  /// Add a new book with chapters and audio files
  Future<String> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String imageUrl,
    required String authorImageUrl,
    required String authorDescription,
    required List<Map<String, dynamic>> chapters,
    required List<File> audioFiles,
    List<File>? alternateAudioFiles, // Optional alternate voice files
    bool isFree = false,
  }) async {
    try {
      if (!categories.contains(genre)) {
        throw ArgumentError('Invalid genre: $genre');
      }

      final String nextId = await _getNextAvailableId();
      print('Adding book with ID: $nextId');

      // 1. Upload audio files to Firebase Storage
      List<String> audioUrls = [];
      List<String> alternateAudioUrls = [];

      // Upload main audio files
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        final fileName = 'chapter${i + 1}.mp3';
        final storageRef = _storage.ref().child('audio/$title/$fileName');

        await storageRef.putFile(audioFile);
        final downloadUrl = await storageRef.getDownloadURL();
        audioUrls.add(downloadUrl);
      }

      // Upload alternate audio files if provided
      if (alternateAudioFiles != null) {
        for (int i = 0; i < alternateAudioFiles.length; i++) {
          final audioFile = alternateAudioFiles[i];
          final fileName = 'chapter${i + 1}_alternate.mp3';
          final storageRef = _storage.ref().child('audio/$title/$fileName');

          await storageRef.putFile(audioFile);
          final downloadUrl = await storageRef.getDownloadURL();
          alternateAudioUrls.add(downloadUrl);
        }
      }

      // 2. Calculate total duration
      int totalDuration = 0;
      for (var chapter in chapters) {
        totalDuration += chapter['duration'] as int;
      }

      // 3. Create book document with chapters
      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'authorImageUrl': authorImageUrl,
        'authorDescription': authorDescription,
        'isFree': isFree,
        'likeCount': 0,
        'totalDuration': totalDuration,
        'chapterCount': chapters.length,
        'createdAt': FieldValue.serverTimestamp(),
        'chapters':
            chapters.asMap().entries.map((entry) {
              final index = entry.key;
              return {
                'title': entry.value['title'],
                'description': entry.value['description'],
                'duration': entry.value['duration'],
                'audioUrl': audioUrls[index],
                'alternateAudioUrl':
                    index < alternateAudioUrls.length
                        ? alternateAudioUrls[index]
                        : '',
                'order': index,
              };
            }).toList(),
      };

      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(nextId)
          .set(bookData);

      print('Book added successfully with ID: $nextId');
      return nextId;
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Get all books across all genres as a Stream
  Stream<List<Map<String, dynamic>>> getAllBooksStream() {
    final streams =
        categories.map((genre) {
          return _firestore
              .collection('books')
              .doc(genre)
              .collection('books')
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) {
                return snapshot.docs.map((doc) {
                  return {'id': doc.id, 'genre': genre, ...doc.data()};
                }).toList();
              });
        }).toList();

    return Rx.combineLatestList(streams).map((lists) {
      final allBooks = lists.expand((list) => list).toList();
      allBooks.sort((a, b) {
        final aTime =
            (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime =
            (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return allBooks;
    });
  }

  /// Get a book by ID
  Future<Map<String, dynamic>?> getBookById(String genre, String id) async {
    try {
      final doc =
          await _firestore
              .collection('books')
              .doc(genre)
              .collection('books')
              .doc(id)
              .get();

      if (!doc.exists) return null;
      return {'id': doc.id, 'genre': genre, ...doc.data()!};
    } catch (e) {
      print('Error getting book: $e');
      return null;
    }
  }

  /// Delete a book by ID and genre
  Future<void> deleteBook(String id, String genre) async {
    try {
      print('Deleting book with ID: $id from genre: $genre');

      // Get the book data to delete audio files
      final bookDoc =
          await _firestore
              .collection('books')
              .doc(genre)
              .collection('books')
              .doc(id)
              .get();

      if (bookDoc.exists) {
        final bookData = bookDoc.data()!;
        final title = bookData['title'];

        // Delete audio files from Storage
        final storageRef = _storage.ref().child('audio/$title');
        final items = await storageRef.listAll();
        for (var item in items.items) {
          await item.delete();
        }
      }

      // Delete the book document
      await _firestore
          .collection('books')
          .doc(genre)
          .collection('books')
          .doc(id)
          .delete();

      print('Book deleted successfully');
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
    required String authorImageUrl,
    required String authorDescription,
    required List<Map<String, dynamic>> chapters,
    required List<File> audioFiles,
    List<File>? alternateAudioFiles,
    bool isFree = false,
  }) async {
    try {
      if (!categories.contains(genre)) {
        throw ArgumentError('Invalid genre: $genre');
      }

      // 1. Upload audio files
      List<String> audioUrls = [];
      List<String> alternateAudioUrls = [];

      // Upload main audio files
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        final fileName = 'chapter${i + 1}.mp3';
        final storageRef = _storage.ref().child('audio/$title/$fileName');

        await storageRef.putFile(audioFile);
        final downloadUrl = await storageRef.getDownloadURL();
        audioUrls.add(downloadUrl);
      }

      // Upload alternate audio files if provided
      if (alternateAudioFiles != null) {
        for (int i = 0; i < alternateAudioFiles.length; i++) {
          final audioFile = alternateAudioFiles[i];
          final fileName = 'chapter${i + 1}_alternate.mp3';
          final storageRef = _storage.ref().child('audio/$title/$fileName');

          await storageRef.putFile(audioFile);
          final downloadUrl = await storageRef.getDownloadURL();
          alternateAudioUrls.add(downloadUrl);
        }
      }

      // 2. Calculate total duration
      int totalDuration = 0;
      for (var chapter in chapters) {
        totalDuration += chapter['duration'] as int;
      }

      // 3. Update book document
      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'authorImageUrl': authorImageUrl,
        'authorDescription': authorDescription,
        'isFree': isFree,
        'totalDuration': totalDuration,
        'chapterCount': chapters.length,
        'updatedAt': FieldValue.serverTimestamp(),
        'chapters':
            chapters.asMap().entries.map((entry) {
              final index = entry.key;
              return {
                'title': entry.value['title'],
                'description': entry.value['description'],
                'duration': entry.value['duration'],
                'audioUrl': audioUrls[index],
                'alternateAudioUrl':
                    index < alternateAudioUrls.length
                        ? alternateAudioUrls[index]
                        : '',
                'order': index,
              };
            }).toList(),
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
