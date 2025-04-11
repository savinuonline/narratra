import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:frontend/models/user_progress.dart';
import 'dart:io';
import '../models/book.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Get user progress data
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('progress')
              .doc('data')
              .get();

      if (doc.exists) {
        return UserProgress.fromMap(doc.data()!);
      } else {
        // Create a new progress document if it doesn't exist
        final newProgress = UserProgress(
          userId: userId,
          inProgressBooks: [],
          completedBooks: [],
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc('data')
            .set(newProgress.toMap());

        return newProgress;
      }
    } catch (e) {
      print('Error getting user progress: $e');
      // Return a default progress object if there's an error
      return UserProgress(
        userId: userId,
        inProgressBooks: [],
        completedBooks: [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Get a stream of user progress for real-time updates
  Stream<UserProgress> getUserProgressStream(String userId) {
    print("Getting user progress stream for user: $userId"); // Debug

    if (userId.isEmpty) {
      print("Empty userId provided to getUserProgressStream");
      return Stream.value(
        UserProgress(
          userId: '',
          inProgressBooks: [],
          completedBooks: [],
          lastUpdated: DateTime.now(),
        ),
      );
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('data')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            print("User progress snapshot exists: ${snapshot.data()}");
            return UserProgress.fromMap(snapshot.data()!);
          } else {
            print("No user progress found, creating a new one");
            // If the document doesn't exist, create a new one
            final newProgress = UserProgress(
              userId: userId,
              inProgressBooks: [],
              completedBooks: [],
              lastUpdated: DateTime.now(),
            );

            // We don't wait for this to complete since it's a stream
            _firestore
                .collection('users')
                .doc(userId)
                .collection('progress')
                .doc('data')
                .set(newProgress.toMap())
                .catchError((e) => print('Error creating user progress: $e'));

            return newProgress;
          }
        });
  }

  /// Get liked books for a user
  Future<List<Book>> getLikedBooks(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('liked_books')
              .get();

      List<Book> likedBooks = [];
      for (var doc in snapshot.docs) {
        final bookId = doc.id;
        final book = await getBookById(bookId);
        if (book != null) {
          likedBooks.add(book);
        }
      }
      return likedBooks;
    } catch (e) {
      print('Error getting liked books: $e');
      return [];
    }
  }

  /// Search for books across all categories
  Future<List<Book>> searchBooks(String query) async {
    final List<Book> results = [];
    final searchQuery = query.toLowerCase();

    for (final cat in categories) {
      final subcollectionRef = _firestore
          .collection('books')
          .doc(cat)
          .collection('books');

      final querySnapshot = await subcollectionRef.get();

      for (final doc in querySnapshot.docs) {
        final bookData = doc.data();
        final title = bookData['title']?.toString().toLowerCase() ?? '';
        final author = bookData['author']?.toString().toLowerCase() ?? '';
        final description =
            bookData['description']?.toString().toLowerCase() ?? '';

        if (title.contains(searchQuery) ||
            author.contains(searchQuery) ||
            description.contains(searchQuery)) {
          results.add(Book.fromMap({...bookData, 'genre': cat}, doc.id));
        }
      }
    }

    return results;
  }

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
            final storageRef = _storage.ref().child(
              'audio/$title/chapter${chapterNum}_voice1.mp3',
            );
            final alternateStorageRef = _storage.ref().child(
              'audio/$title/chapter${chapterNum}_voice2.mp3',
            );

            try {
              final audioUrl = await storageRef.getDownloadURL();
              chaptersData[i]['audioUrl'] = audioUrl;
              print('Audio URL for chapter $chapterNum: $audioUrl');

              try {
                final alternateAudioUrl =
                    await alternateStorageRef.getDownloadURL();
                chaptersData[i]['alternateAudioUrl'] = alternateAudioUrl;
                print(
                  'Alternate audio URL for chapter $chapterNum: $alternateAudioUrl',
                );
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
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('liked_books')
              .doc(bookId)
              .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if book is liked: $e');
      return false;
    }
  }

  /// Toggle like status for a book.
  Future<bool> toggleBookLike(String userId, String bookId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('liked_books')
          .doc(bookId);

      final doc = await docRef.get();

      if (doc.exists) {
        // Unlike: Remove the book from liked_books collection
        await docRef.delete();
        print("Unliked book $bookId for user $userId");
        return false;
      } else {
        // Like: Add the book to liked_books collection
        await docRef.set({'likedAt': FieldValue.serverTimestamp()});
        print("Liked book $bookId for user $userId");
        return true;
      }
    } catch (e) {
      print('Error toggling book like: $e');
      throw e;
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
    // Use the current authenticated user's ID if a hardcoded value is passed
    if (userId == 'USER_ID') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
      } else {
        print(
          'Error: No authenticated user found when saving listening progress',
        );
        return;
      }
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('listening_progress')
        .doc(bookId)
        .set({'position': position.inSeconds, 'updatedAt': DateTime.now()});

    // Also add this book to the user's in-progress books list
    await addBookToInProgress(userId, bookId);
  }

  /// Add a book to the user's in-progress list if it's not already there
  Future<void> addBookToInProgress(String userId, String bookId) async {
    try {
      // Get the current progress document
      final progressDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('progress')
              .doc('data')
              .get();

      if (progressDoc.exists) {
        // Update the in-progress books list if the book is not already in it
        final inProgressBooks = List<String>.from(
          progressDoc.data()?['inProgressBooks'] ?? [],
        );
        if (!inProgressBooks.contains(bookId)) {
          inProgressBooks.add(bookId);
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('progress')
              .doc('data')
              .update({
                'inProgressBooks': inProgressBooks,
                'lastUpdated': FieldValue.serverTimestamp(),
              });
          print('Added book $bookId to in-progress list for user $userId');
        }
      } else {
        // Create a new progress document if it doesn't exist
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc('data')
            .set({
              'userId': userId,
              'inProgressBooks': [bookId],
              'completedBooks': [],
              'lastUpdated': FieldValue.serverTimestamp(),
            });
        print(
          'Created new progress document with book $bookId for user $userId',
        );
      }
    } catch (e) {
      print('Error adding book to in-progress list: $e');
    }
  }

  /// Get listening progress for an audiobook.
  Future<Duration?> getListeningProgress(String userId, String bookId) async {
    // Use the current authenticated user's ID if a hardcoded value is passed
    if (userId == 'USER_ID') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
      } else {
        print(
          'Error: No authenticated user found when getting listening progress',
        );
        return null;
      }
    }

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

  /// Get user's library stream (liked books and playlists)
  Stream<Map<String, dynamic>> getUserLibraryStream(String userId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return Rx.combineLatest2(
      getLikedBooksStream(user.uid),
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map(
                      (doc) => {
                        'id': doc.id,
                        'name': doc.data()['name'] as String,
                        'books': List<String>.from(doc.data()['books'] ?? []),
                      },
                    )
                    .toList(),
          ),
      (List<Book> likedBooks, List<Map<String, dynamic>> playlists) => {
        'likedBooks': likedBooks,
        'playlists': playlists,
      },
    );
  }

  /// Create a new playlist
  Future<String> createPlaylist(
    String userId,
    String name,
    String bookId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final playlistRef =
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('playlists')
              .doc();

      await playlistRef.set({
        'name': name,
        'books': [bookId],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return playlistRef.id;
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final playlistRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(playlistId);

      final playlistDoc = await playlistRef.get();

      if (!playlistDoc.exists) {
        throw Exception('Playlist not found');
      }

      final books = List<String>.from(playlistDoc.data()?['books'] ?? []);
      if (!books.contains(bookId)) {
        books.add(bookId);
        await playlistRef.update({'books': books});
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
              .map((doc) => Book.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get user profile
  Future<UserProfile> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('Users').doc(user.uid).get();

    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    } else {
      // Create new profile if it doesn't exist
      final newProfile = UserProfile(
        userId: user.uid,
        email: user.email ?? '',
        firstName: '',
        lastName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .set(newProfile.toMap());

      return newProfile;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('Users').doc(user.uid).set(profile.toMap());
  }

  Stream<List<Book>> getLikedBooksAsStream(String userId) {
    print("Getting liked books stream for user: $userId"); // Debug

    if (userId.isEmpty) {
      print("Empty userId provided to getLikedBooksAsStream");
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_books')
        .snapshots()
        .asyncMap((snapshot) async {
          print("Liked books snapshot: ${snapshot.docs.length} docs");
          List<Book> books = [];
          for (var doc in snapshot.docs) {
            final bookId = doc.id;
            print("Fetching liked book with ID: $bookId");
            final book = await getBookById(bookId);
            if (book != null) {
              books.add(book);
            }
          }
          print("Returning ${books.length} liked books");
          return books;
        });
  }

  /// Get a sample book for testing purposes
  Future<Book?> getSampleBook() async {
    try {
      // Get the trending books
      final trendingBooks = await getTrendingBooks();
      if (trendingBooks.isNotEmpty) {
        return trendingBooks.first;
      }

      // Fallback to any book from any genre
      for (final genre in categories) {
        final snapshot =
            await _firestore
                .collection('books')
                .doc(genre)
                .collection('books')
                .limit(1)
                .get();

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          return Book.fromMap({...doc.data(), 'genre': genre}, doc.id);
        }
      }

      return null;
    } catch (e) {
      print('Error getting sample book: $e');
      return null;
    }
  }

  /// Add a sample book to the user's in-progress list for testing
  Future<void> addSampleBookToInProgress(String userId) async {
    try {
      final sampleBook = await getSampleBook();
      if (sampleBook != null) {
        await addBookToInProgress(userId, sampleBook.id);
        print(
          'Added sample book ${sampleBook.id} to in-progress for user $userId',
        );
      }
    } catch (e) {
      print('Error adding sample book: $e');
    }
  }

  /// Mark a book as completed, moving it from inProgressBooks to completedBooks
  Future<void> markBookAsCompleted(String userId, String bookId) async {
    try {
      // Get the current progress document
      final progressDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('progress')
              .doc('data')
              .get();

      if (progressDoc.exists) {
        final data = progressDoc.data()!;
        final inProgressBooks = List<String>.from(
          data['inProgressBooks'] ?? [],
        );
        final completedBooks = List<String>.from(data['completedBooks'] ?? []);

        // Remove from inProgressBooks if present
        if (inProgressBooks.contains(bookId)) {
          inProgressBooks.remove(bookId);
        }

        // Add to completedBooks if not already there
        if (!completedBooks.contains(bookId)) {
          completedBooks.add(bookId);
        }

        // Update the progress document
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc('data')
            .update({
              'inProgressBooks': inProgressBooks,
              'completedBooks': completedBooks,
              'lastUpdated': FieldValue.serverTimestamp(),
            });

        print('Marked book $bookId as completed for user $userId');
      } else {
        // Create a new progress document if it doesn't exist
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('progress')
            .doc('data')
            .set({
              'userId': userId,
              'inProgressBooks': [],
              'completedBooks': [bookId],
              'lastUpdated': FieldValue.serverTimestamp(),
            });
        print(
          'Created new progress document with completed book $bookId for user $userId',
        );
      }
    } catch (e) {
      print('Error marking book as completed: $e');
      throw e;
    }
  }

  Future<void> updateSubscription(
    String userId,
    Map<String, dynamic> subscription,
  ) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'subscription': subscription,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSubscription(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      return doc.data()?['subscription'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting subscription: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>?> getSubscriptionStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['subscription'] as Map<String, dynamic>?);
  }
}
