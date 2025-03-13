import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/book.dart';
import 'package:frontend/pages/player_screen.dart';
import '../services/firebase_service.dart';

class BookInfoPage extends StatefulWidget {
  final String bookId;

  const BookInfoPage({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Book?> _bookFuture;

  @override
  void initState() {
    super.initState();
    _debugDatabaseStructure(); // Add this line
    _bookFuture = _firebaseService.getBookById(widget.bookId);
  }

  void _debugDatabaseStructure() async {
    try {
      print('======= DATABASE STRUCTURE DEBUG =======');

      // Check root collections and if 'books' collection exists
      final booksCollection = FirebaseFirestore.instance.collection('books');
      print('Root collections:');
      print('- books');
      final booksSnapshot = await booksCollection.get();
      print('Books collection has ${booksSnapshot.docs.length} documents');

      if (booksSnapshot.docs.isNotEmpty) {
        // Check first genre
        final firstGenre = booksSnapshot.docs.first;
        print('First genre: ${firstGenre.id}');

        // Check books in first genre
        final booksInGenre =
            await booksCollection.doc(firstGenre.id).collection('books').get();

        print('Genre ${firstGenre.id} has ${booksInGenre.docs.length} books');

        if (booksInGenre.docs.isNotEmpty) {
          final firstBook = booksInGenre.docs.first;
          print('Sample book: ID=${firstBook.id}, Data=${firstBook.data()}');
        }
      }

      print('======= END DEBUG =======');
    } catch (e) {
      print('Error during structure debug: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c0c0c),
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: const Color(0xFF402e7a),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Book?>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading book: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Book not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final book = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        book.imageUrl.startsWith('http')
                            ? Image.network(
                              book.imageUrl,
                              height: 250,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              book.imageUrl,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Author
                Text(
                  'By ${book.author}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),

                const SizedBox(height: 16),

                // Genre
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(book.genre),
                      backgroundColor: const Color(0xFF4c3bcf),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Play button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(book: book),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF402e7a),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Play Audiobook',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlayerScreen extends StatelessWidget {
  final Book book;

  const PlayerScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Now Playing: ${book.title}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the book cover and title
            book.imageUrl.startsWith('assets/')
                ? Image.asset(book.imageUrl, height: 200)
                : Image.network(book.imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('by ${book.author}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Implement your audio playback logic here
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
