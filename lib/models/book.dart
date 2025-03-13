// lib/models/book.dart
class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String imageUrl;
  final String description;
  final String audioUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.imageUrl,
    required this.description,
    required this.audioUrl,
  });

  // Convert Book to map for DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'imageUrl': imageUrl,
      'description': description,
      'audioUrl': audioUrl,
    };
  }

  // Make sure this method can handle your data structure
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '', // This might be missing if using document ID
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Add other fields as needed
      genre: map['genre'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
    );
  }
}
