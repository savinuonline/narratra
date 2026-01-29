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
  final double rating;

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
    this.rating = 0.0,
  });

  Duration get totalDuration => Duration(
    seconds: chapters.fold(
      0,
      (sum, chapter) => sum + chapter.duration.inSeconds,
    ),
  );

  int get totalDurationInSeconds =>
      chapters.fold(0, (sum, chapter) => sum + chapter.duration.inSeconds);

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      genre: map['genre'] ?? '',
      chapters:
          (map['chapters'] as List<dynamic>?)
              ?.map((chapter) => Chapter.fromMap(chapter))
              .toList() ??
          [],
      likeCount: map['likeCount'] ?? 0,
      description: map['description'] ?? '',
      authorDescription: map['authorDescription'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  // Add an empty Book factory constructor for null safety handling
  factory Book.empty() {
    return Book(
      id: '',
      title: '',
      author: '',
      imageUrl: '',
      genre: '',
      chapters: [],
      likeCount: 0,
      description: '',
      authorDescription: '',
      rating: 0.0,
    );
  }
}
