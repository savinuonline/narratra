// lib/models/book.dart
class Book {
  final String id;
  final String title;
  final String author;
  final String authorDescription;
  final String authorImageUrl;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final String genre;
  final bool isFree;
  final int likeCount; // New field for the number of likes

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.authorDescription,
    required this.authorImageUrl,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.genre,
    required this.isFree,
    required this.likeCount,
  });

  // Convert Book to map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'authorDescription': authorDescription,
      'authorImageUrl': authorImageUrl,
      'description': description,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'genre': genre,
      'isFree': isFree,
      'likeCount': likeCount,
    };
  }

  // Factory constructor for creating a Book from a map
  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      authorDescription: map['authorDescription'] ?? 'No author description available.',
      authorImageUrl: map['authorImageUrl'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      genre: map['genre'] ?? '',
      isFree: map['isFree'] ?? false,
      likeCount: map['likeCount'] != null ? map['likeCount'] as int : 0,
    );
  }
}
