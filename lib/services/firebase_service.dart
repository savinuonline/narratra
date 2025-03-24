import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Update this list so it matches exactly the doc names
  /// you have under the top-level "books" collection in Firestore.
  final List<String> categories = [
    "Children's literature",
    "Thriller",
    "Fiction",
    "Horror",
    "Romance",
    "Adventure",
  ];

  /// "Trending" books: docs with likeCount >= 1 in each subcollection,

  Future<List<Book>> getTrendingBooks() async {
    final List<Book> trending = [];

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      // Query docs where likeCount >= 1, ordered descending by likeCount
      final querySnapshot =
          await subcollectionRef
              .where('likeCount', isGreaterThanOrEqualTo: 1)
              .orderBy('likeCount', descending: true)
              .get();

      final catBooks =
          querySnapshot.docs
              .map((doc) => Book.fromMap({...doc.data(), 'genre': cat}, doc.id))
              .toList();
      trending.addAll(catBooks);
    }

    // Globally sort by likeCount (descending) and return the top 10 books
    trending.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    return trending.take(10).toList();
  }

  /// "Recommended" books: based on user's selectedGenres.
  Future<List<Book>> getRecommendedBooks(String uid) async {
    try {
      print('Available categories: $categories');

      // Get user document from the correct collection
      final userDoc = await _firestore.collection('Users').doc(uid).get();
      if (!userDoc.exists) {
        print('User document not found for uid: $uid');
        return [];
      }

      final userData = userDoc.data()!;
      print('User data found: ${userData.toString()}');

      final userGenres = List<String>.from(userData['preferences'] ?? []);
      print('Found user preferences: $userGenres');

      if (userGenres.isEmpty) {
        print('No preferences found for user');
        return [];
      }

      final List<Book> recommended = [];
      for (final genre in userGenres) {
        print('Fetching books for genre: $genre');
        if (!categories.contains(genre)) {
          print('Warning: Genre $genre is not in available categories!');
          continue;
        }

        final subcollectionRef = _firestore
            .collection('books')
            .doc(genre)
            .collection('books');

        final querySnapshot = await subcollectionRef.get();
        print('Found ${querySnapshot.docs.length} books in $genre');

        final genreBooks =
            querySnapshot.docs
                .map(
                  (doc) =>
                      Book.fromMap({...doc.data(), 'genre': genre}, doc.id),
                )
                .toList();

        recommended.addAll(genreBooks);
        print(
          'Added ${genreBooks.length} books from $genre to recommendations',
        );
      }

      print('Total books found before shuffle: ${recommended.length}');
      // Shuffle the recommendations for variety
      if (recommended.isNotEmpty) {
        recommended.shuffle();
        final result = recommended.take(10).toList();
        print('Returning ${result.length} recommended books');
        return result;
      }

      print('No books found in any of the user\'s preferred genres');
      return recommended;
    } catch (e) {
      print('Error fetching recommended books: $e');
      return [];
    }
  }

  /// "Today For You": gather *all* books from all categories, shuffle,
  /// and return 5 random ones.
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

  /// Update user's selected genres in Firestore.
  Future<void> updateUserGenres(String uid, List<String> genres) async {
    try {
      await _firestore.collection('Users').doc(uid).update({
        'preferences': genres,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Successfully updated genres for user $uid: $genres');
    } catch (e) {
      print('Error updating genres: $e');
      rethrow;
    }
  }

  /// Get a single book by ID with author details.
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
          final title = bookData['title'] as String;

          // Get author details
          final authorDetails = await getAuthorByName(bookData['author'] ?? '');

          // Get chapters data and construct audio URLs
          final List<Map<String, dynamic>> chaptersData = 
              List<Map<String, dynamic>>.from(bookData['chapters'] ?? []);

          // Update each chapter with the correct audio URLs
          for (int i = 0; i < chaptersData.length; i++) {
            final chapterNum = i + 1;
            final storageRef = _storage.ref().child('audio/$title/chapter${chapterNum}_voice1.mp3');
            final alternateStorageRef = _storage.ref().child('audio/$title/chapter${chapterNum}_voice2.mp3');

            try {
              final audioUrl = await storageRef.getDownloadURL();
              chaptersData[i]['audioUrl'] = audioUrl;
              print('Audio URL for chapter $chapterNum: $audioUrl');

              try {
                final alternateAudioUrl = await alternateStorageRef.getDownloadURL();
                chaptersData[i]['alternateAudioUrl'] = alternateAudioUrl;
                print('Alternate audio URL for chapter $chapterNum: $alternateAudioUrl');
              } catch (e) {
                print('No alternate voice available for chapter $chapterNum');
                chaptersData[i]['alternateAudioUrl'] = '';
              }
            } catch (e) {
              print('Error getting audio URL for chapter $chapterNum: $e');
              chaptersData[i]['audioUrl'] = '';
              chaptersData[i]['alternateAudioUrl'] = '';
            }
          }

          // Merge book data with genre, author details, and updated chapters
          final mergedData = {
            ...bookData,
            'genre': genre,
            'authorDescription':
                authorDetails?['description'] ??
                'No author description available.',
            'authorImageUrl': authorDetails?['imageUrl'] ?? '',
            'chapters': chaptersData,
          };

          return Book.fromMap(mergedData, bookId);
        }
      }

      return null;
    } catch (e) {
      print('Error in getBookById: $e');
      return null;
    }
  }

  /// Get the next available sequential ID for a new book.
  Future<String> _getNextBookId() async {
    int highestId = 0;

    for (final genre in categories) {
      final snapshot =
          await _firestore
              .collection('books')
              .doc(genre)
              .collection('books')
              .get();

      for (final doc in snapshot.docs) {
        final currentId = int.tryParse(doc.id) ?? 0;
        if (currentId > highestId) {
          highestId = currentId;
        }
      }
    }

    return (highestId + 1).toString().padLeft(3, '0');
  }

  /// Add a new book to Firestore with a sequential ID.
  Future<String> addBook({
    required String title,
    required String author,
    required String description,
    required String genre,
    required String imageUrl,
    required String authorImageUrl,
    required String authorDescription,
    required List<Map<String, dynamic>> chapters,
    required List<File> audioFiles,
  }) async {
    try {
      if (!categories.contains(genre)) {
        throw ArgumentError(
          'Invalid genre: $genre. Must be one of: $categories',
        );
      }

      // 1. Upload audio files to Firebase Storage
      List<String> audioUrls = [];
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        final fileName = 'chapter${i + 1}.mp3';
        final storageRef = _storage.ref().child('audio/$title/$fileName');

        // Upload the file
        await storageRef.putFile(audioFile);
        // Get the download URL
        final downloadUrl = await storageRef.getDownloadURL();
        audioUrls.add(downloadUrl);
      }

      // 2. Calculate total duration
      int totalDuration = 0;
      for (var chapter in chapters) {
        totalDuration += chapter['duration'] as int;
      }

      // 3. Create book document
      final bookRef = await _firestore.collection('books').add({
        'title': title,
        'author': author,
        'description': description,
        'genre': genre,
        'imageUrl': imageUrl,
        'authorImageUrl': authorImageUrl,
        'authorDescription': authorDescription,
        'totalDuration': totalDuration,
        'likeCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'chapters':
            chapters.asMap().entries.map((entry) {
              return {
                'title': entry.value['title'],
                'description': entry.value['description'],
                'duration': entry.value['duration'],
                'audioUrl': audioUrls[entry.key],
                'order': entry.key,
              };
            }).toList(),
      });

      return bookRef.id;
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Get a stream of liked books for a user.
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

  /// Check if a book is liked by the user.
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

  /// Toggle like status for a book.
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

  /// Increment the like count for a given book across categories.
  Future<void> incrementBookLikeCount(String bookId) async {
    for (final cat in categories) {
      final docRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books')
          .doc(bookId);

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({'likeCount': FieldValue.increment(1)});
        break;
      }
    }
  }

  /// Decrement the like count for a given book across categories.
  Future<void> decrementBookLikeCount(String bookId) async {
    for (final cat in categories) {
      final docRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books')
          .doc(bookId);

      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({'likeCount': FieldValue.increment(-1)});
        break;
      }
    }
  }

  /// Get a stream of saved audiobooks for a user.
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

  /// Check if an audiobook is saved by the user.
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

  /// Toggle save status of an audiobook.
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

  /// Save listening progress for an audiobook.
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

  /// Get listening progress for an audiobook.
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

  /// Get listening history for a user.
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

  /// Get author details by name - needed for book details.
  Future<Map<String, dynamic>?> getAuthorByName(String name) async {
    try {
      final doc = await _firestore.collection('authors').doc(name).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting author: $e');
      return null;
    }
  }

  /// Get a stream of all authors.
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

  /// Get a stream of the user's library including liked books and playlists
  Stream<Map<String, dynamic>> getUserLibraryStream(String userId) {
    return Rx.combineLatest2(
      getLikedBooksStream(userId),
      _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .snapshots(),
      (List<Book> likedBooks, QuerySnapshot playlistsSnapshot) async {
        final playlists = await Future.wait(
          playlistsSnapshot.docs.map((doc) async {
            final playlistData = doc.data() as Map<String, dynamic>;
            final bookIds = List<String>.from(playlistData['books'] ?? []);

            // Fetch all books in the playlist
            final books = await Future.wait(
              bookIds.map((bookId) async {
                final book = await getBookById(bookId);
                return book;
              }),
            );

            // Filter out null books and create playlist map
            final validBooks =
                books.where((book) => book != null).cast<Book>().toList();

            return {
              'id': doc.id,
              'name': playlistData['name'],
              'books': validBooks,
              'createdAt': playlistData['createdAt'],
            };
          }),
        );

        return {'likedBooks': likedBooks, 'playlists': playlists};
      },
    ).asyncMap((future) => future);
  }

  /// Create a new playlist
  Future<String> createPlaylist(
    String userId,
    String name,
    String bookId,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'playlists': [
            {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': name,
              'books': [bookId],
            },
          ],
        });
        return DateTime.now().millisecondsSinceEpoch.toString();
      }

      final playlists = List<Map<String, dynamic>>.from(
        userDoc.data()?['playlists'] ?? [],
      );
      final newPlaylist = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'books': [bookId],
      };

      playlists.add(newPlaylist);
      await userRef.update({'playlists': playlists});

      return newPlaylist['id'] as String;
    } catch (e) {
      print('Error creating playlist: $e');
      return '';
    }
  }

  /// Rename a playlist by name
  Future<void> renamePlaylist(
    String userId,
    String playlistId,
    String newName,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update({'name': newName});
    } catch (e) {
      print('Error renaming playlist: $e');
      rethrow;
    }
  }

  /// Add a book to an existing playlist
  Future<void> addBookToPlaylist(
    String userId,
    String playlistId,
    String bookId,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) return;

      final playlists = List<Map<String, dynamic>>.from(
        userDoc.data()?['playlists'] ?? [],
      );
      final playlistIndex = playlists.indexWhere((p) => p['id'] == playlistId);

      if (playlistIndex != -1) {
        final books = List<String>.from(
          playlists[playlistIndex]['books'] ?? [],
        );
        if (!books.contains(bookId)) {
          books.add(bookId);
          playlists[playlistIndex]['books'] = books;
          await userRef.update({'playlists': playlists});
        }
      }
    } catch (e) {
      print('Error adding book to playlist: $e');
      rethrow;
    }
  }

  /// Remove a book from a playlist
  Future<void> removeBookFromPlaylist(
    String userId,
    String playlistId,
    String bookId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .update({
            'books': FieldValue.arrayRemove([bookId]),
          });
    } catch (e) {
      print('Error removing book from playlist: $e');
      rethrow;
    }
  }

  /// Delete a playlist
  Future<void> deletePlaylist(String userId, String playlistId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Book>> getBooksByGenre(String genre) {
    return _firestore
        .collection('books')
        .doc(genre)
        .collection('books')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Book.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }
}
