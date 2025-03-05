// lib/models/book.dart
class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String imageUrl;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.imageUrl,
    required this.description,
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
    };
  }

  // Create Book from map (e.g. Firestore doc)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
