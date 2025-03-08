import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/book.dart';
import 'player_screen.dart'; // Import the player screen

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // For demonstration purposes, we'll use a FirebaseService to get books.
  // In a real implementation, these methods should query your backend.
  final FirebaseService _firebaseService = FirebaseService();

  late Future<List<Book>> trendingBooksFuture;
  late Future<List<Book>> recommendedBooksFuture;
  late Future<List<Book>> todayBooksFuture;
  late Future<List<Book>> freeBooksFuture;

  // Bottom navigation index
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    trendingBooksFuture = _firebaseService.getTrendingBooks();
    recommendedBooksFuture =
        _firebaseService.getRecommendedBooks(widget.user.uid);
    todayBooksFuture = _firebaseService.getTodayForYouBooks();
    freeBooksFuture = _firebaseService.getFreeBooks();
  }

  void _showBookDetails(Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookDetailSheet(book: book),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define your navigation items once
    final List<NavigationItem> navigationItems = [
      NavigationItem(icon: 'Home.svg', label: 'Home'),
      NavigationItem(icon: 'Search.svg', label: 'Search'),
      NavigationItem(icon: 'Library.svg', label: 'Library'),
      NavigationItem(icon: 'Profile.svg', label: 'Profile'),
    ];

    return Scaffold(
      appBar: _buildCustomAppBar(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Add any additional navigation logic if needed.
        },
        navigationItems: navigationItems,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              CategorySection(
                title: "Trending",
                booksFuture: trendingBooksFuture,
                onBookTap: _showBookDetails,
              ),
              CategorySection(
                title: "Recommends",
                booksFuture: recommendedBooksFuture,
                onBookTap: _showBookDetails,
              ),
              CategorySection(
                title: "Today For You",
                booksFuture: todayBooksFuture,
                onBookTap: _showBookDetails,
              ),
              CategorySection(
                title: "Free Books",
                booksFuture: freeBooksFuture,
                onBookTap: _showBookDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Greeting section at the top
  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${widget.user.displayName}!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Good Evening",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // Avatar from local asset
        const CircleAvatar(
          radius: 26,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ],
    );
  }

  /// Search bar placeholder
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search audiobooks...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// A widget that builds a category section with a horizontally scrolling list of book cards.
class CategorySection extends StatelessWidget {
  final String title;
  final Future<List<Book>> booksFuture;
  final ValueChanged<Book> onBookTap;

  const CategorySection({
    Key? key,
    required this.title,
    required this.booksFuture,
    required this.onBookTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Book>>(
          future: booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    'Error loading $title',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    'No books available in $title',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            final books = snapshot.data!;
            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: books.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return GestureDetector(
                    onTap: () => onBookTap(book),
                    child: BookCard(book: book),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Horizontal book card widget using asset images
  Widget _buildHorizontalBookCard(Book book) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the book cover image from asset (or network if needed)
            if (book.imageUrl.startsWith('lib/'))
              Image.asset(
                book.imageUrl,
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              )
            else
              Image.network(
                book.imageUrl,
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              ),
            // Book title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}

// A widget for showing detailed book information in a bottom sheet.
class BookDetailSheet extends StatelessWidget {
  final Book book;

  const BookDetailSheet({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Author: ${book.author}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              "Genre: ${book.genre}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              book.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("Play"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
