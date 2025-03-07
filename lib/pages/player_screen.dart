import 'package:flutter/material.dart';
import '../models/book.dart';

class PlayerScreen extends StatelessWidget {
  final Book book;

  const PlayerScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Now Playing: ${book.title}"),
      ),
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
            Text(
              "by ${book.author}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Implement your audio playback logic here
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Play Now"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
