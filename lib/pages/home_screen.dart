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
    _recommendedBooksFuture =
        _firebaseService.getRecommendedBooks(widget.user.uid);
  }

  Future<void> _refreshRecommendations() async {
    setState(() {
      _recommendedBooksFuture =
          _firebaseService.getRecommendedBooks(widget.user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the default AppBar if you want a custom top section
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
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

            // Wrap everything in a SingleChildScrollView
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(),
                  const SizedBox(height: 24),
                  _buildRecommendedSection(books),
                  const SizedBox(height: 24),
                  _buildNewlyArrivedSection(books),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshRecommendations,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// Top greeting + avatar
  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting texts
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Savinu!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Good Evening!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // Profile avatar (placeholder image)
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            "https://via.placeholder.com/150",
          ),
        )
      ],
    );
  }

  /// Horizontal list of recommended books
  Widget _buildRecommendedSection(List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECOMMENDED FOR YOU",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240, // Enough space for the horizontal card
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (context, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildHorizontalBookCard(book);
            },
          ),
        ),
      ],
    );
  }

  /// Card style for horizontal "recommended" items
  Widget _buildHorizontalBookCard(Book book) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Image.network(
              book.imageUrl,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
            ),
            // Book details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Author: ${book.author}",
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Example rating row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Icon(Icons.star_half, color: Colors.amber, size: 16),
                  Icon(Icons.star_outline, color: Colors.amber, size: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Vertical list for "Our Newly Arrived"
  Widget _buildNewlyArrivedSection(List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Our Newly Arrived",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // We'll just create a vertical list of cards
        Column(
          children: books.map((book) => _buildVerticalBookCard(book)).toList(),
        )
      ],
    );
  }

  /// Card style for vertical "newly arrived" items
  Widget _buildVerticalBookCard(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.imageUrl,
              height: 100,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Book details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Author: ${book.author}",
                  style: TextStyle(color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Genre: ${book.genre}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                // Example of a duration or rating
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("4h 45m"),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
