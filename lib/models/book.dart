// lib/models/book.dart
class Chapter {
  final String title;
  final String description;
  final Duration duration;
  final String audioUrl;

  Chapter({
    required this.title,
    required this.description,
    required this.duration,
    required this.audioUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration.inSeconds,
      'audioUrl': audioUrl,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: Duration(seconds: map['duration'] ?? 0),
      audioUrl: map['audioUrl'] ?? '',
    );
  }
}

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
  final List<Chapter> chapters;

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
    this.chapters = const [],
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
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
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
      chapters: (map['chapters'] as List<dynamic>?)
          ?.map((chapter) => Chapter.fromMap(chapter))
          .toList() ?? [],
    );
  }
}
