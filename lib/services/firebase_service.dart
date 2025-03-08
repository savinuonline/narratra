// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/book.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Update user’s selected genres in Firestore
  Future<void> updateUserGenres(String uid, List<String> genres) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'selectedGenres': genres,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all books from Firestore (assumes a 'books' collection)
  Future<List<Book>> getAllBooks() async {
    try {
      final querySnapshot = await _firestore.collection('books').get();
      return querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Simple recommendation by matching user’s selected genres to book’s genre
  Future<List<Book>> getRecommendedBooks(String uid) async {
    // 1) Get the user
    final user = await getUserData(uid);
    if (user == null) return [];

    // 2) Fetch all books
    final allBooks = await getAllBooks();

    // 3) Filter books by user’s selectedGenres
    final recommended = allBooks.where((book) {
      return user.selectedGenres.contains(book.genre);
    }).toList();

    return recommended;
  }

  // -------------- NEW METHODS BELOW --------------

  // Example: For demonstration only.
  // In a real app, you might store a "views" or "popularity" field in Firestore
  // and query or sort by that field to get trending.
  Future<List<Book>> getTrendingBooks() async {
    final allBooks = await getAllBooks();
    // Sort or filter as needed. For now, just return them all.
    return allBooks;
  }

  // Example: For demonstration only.
  // Maybe "Today For You" is a random or curated subset.
  // Or you could store a daily pick in Firestore.
  Future<List<Book>> getTodayForYouBooks() async {
    final allBooks = await getAllBooks();
    // Return them all or pick some subset.
    // For now, returning them all for demonstration.
    return allBooks;
  }

  // Example: For demonstration only.
  // If your Book model has a "price" or "isFree" field, filter accordingly.
  Future<List<Book>> getFreeBooks() async {
    final allBooks = await getAllBooks();
    // Filter out only free books if you have a price field.
    // For now, returning everything.
    return allBooks;
  }
}
