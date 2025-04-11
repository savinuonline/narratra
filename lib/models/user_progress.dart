import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final List<String> inProgressBooks;
  final List<String> completedBooks;
  final DateTime lastUpdated;

  UserProgress({
    required this.userId,
    required this.inProgressBooks,
    required this.completedBooks,
    required this.lastUpdated,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      userId: map['userId'] ?? '',
      inProgressBooks: List<String>.from(map['inProgressBooks'] ?? []),
      completedBooks: List<String>.from(map['completedBooks'] ?? []),
      lastUpdated: _parseDate(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'inProgressBooks': inProgressBooks,
      'completedBooks': completedBooks,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Helper method to parse date from Firestore Timestamp
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      return DateTime.now();
    }
  }

  // Create a copy of this object with some fields replaced
  UserProgress copyWith({
    String? userId,
    List<String>? inProgressBooks,
    List<String>? completedBooks,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      inProgressBooks: inProgressBooks ?? this.inProgressBooks,
      completedBooks: completedBooks ?? this.completedBooks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 