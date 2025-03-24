// lib/models/book.dart
class Chapter {
  final String title;
  final String description;
  final Duration duration;
  final String audioUrl;
  final String alternateAudioUrl;

  Chapter({
    required this.title,
    required this.description,
    required this.duration,
    required this.audioUrl,
    this.alternateAudioUrl = '',
  });

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: Duration(seconds: map['duration'] ?? 0),
      audioUrl: map['audioUrl'] ?? '',
      alternateAudioUrl: map['alternateAudioUrl'] ?? '',
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String genre;
  final List<Chapter> chapters;
  int likeCount;
  final String description;
  final String authorDescription;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.genre,
    this.chapters = const [],
    this.likeCount = 0,
    required this.description,
    this.authorDescription = '',
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      genre: map['genre'] ?? '',
      chapters: (map['chapters'] as List<dynamic>?)
          ?.map((chapter) => Chapter.fromMap(chapter))
          .toList() ?? [],
      likeCount: map['likeCount'] ?? 0,
      description: map['description'] ?? '',
      authorDescription: map['authorDescription'] ?? '',
    );
  }
}
