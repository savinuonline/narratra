import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/book.dart';
import '../services/firebase_service.dart'; // Assume you have methods to fetch books
import 'player_screen.dart'; // Screen for playing audiobooks
import '../widgets/custom_bottom_nav_bar.dart'; // Custom bottom nav bar module

class HomeScreen extends StatefulWidget {
  final UserModel user;

  // Fix the "key could be a super parameter" lint
  const HomeScreen({super.key, required this.user});

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

  // Fix the undefined name '_selectedIndex'
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

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${widget.user.displayName}!",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Good Evening",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Add your notification action here.
              // For example, navigate to a notifications screen or show a dialog.
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        // Fix "withOpacity" to "withAlpha(25)" or "withAlpha(230)"
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
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
              height: 250,
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
}

// A card widget to display a book's cover, title, and author.
class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: 8),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display the book cover image from asset (or network if needed)
            if (book.imageUrl.startsWith('lib/'))
              Image.asset(
                book.imageUrl,
                height: 150,
                width: 110,
                fit: BoxFit.cover,
              )
            else
              Image.network(
                book.imageUrl,
                height: 150,
                width: 110,
                fit: BoxFit.cover,
              ),
            // Book title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                book.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Book author
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Text(
                book.author,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
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

            // >>>>>> Like button added here <<<<<<
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Example: call a "likeBook" method from your FirebaseService
                  // e.g.: await FirebaseService().likeBook(book.id, userId);
                  // For demonstration, we just close the sheet:
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.thumb_up),
                label: const Text("Like"),
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
            const SizedBox(height: 12),

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
