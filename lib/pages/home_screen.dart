// lib/pages/home_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Book>> _recommendedBooksFuture;

  @override
  void initState() {
    super.initState();
    _recommendedBooksFuture = _firebaseService.getRecommendedBooks(widget.user.uid);
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _recommendedBooksFuture = _firebaseService.getRecommendedBooks(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended For You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _recommendedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading recommendations'));
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No recommendations yet'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookCard(book);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      child: Column(
        children: [
          Image.network(
            book.imageUrl,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(book.author),
          Text('Genre: ${book.genre}'),
        ],
      ),
    );
  }
}
