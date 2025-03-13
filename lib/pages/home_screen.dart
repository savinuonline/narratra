import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final FirebaseService _firebaseService = FirebaseService();

  late Future<List<Book>> trendingBooksFuture;
  late Future<List<Book>> recommendedBooksFuture;
  late Future<List<Book>> todayBooksFuture;
  late Future<List<Book>> freeBooksFuture;

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
                title: "Uniquely Yours",
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
          // User greeting
          Text(
            "Hello, ${widget.user.displayName}!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff000000),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Good Evening",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xff000000),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
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
    // If it's "Trending", make the font bigger
    final double categoryFontSize = title == "Trending" ? 22 : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: categoryFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xff000000),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Book>>(
          future: booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
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
                    style: GoogleFonts.poppins(
                      color: const Color(0xff000000),
                      fontSize: 16,
                    ),
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
                    style: GoogleFonts.poppins(
                      color: const Color(0xff000000),
                      fontSize: 16,
                    ),
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

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Let the column wrap content
      children: [
        Container(
          width: 150,
          height: 180,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF68B0AB),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: book.imageUrl.startsWith('lib/')
                  ? Image.asset(
                book.imageUrl,
                width: 110,
                height: 150,
                fit: BoxFit.contain, // Keep proportions
              )
                  : Image.network(
                book.imageUrl,
                width: 110,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            book.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: const Color(0xFF000000),
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 4),

        // Author
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            book.author,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF000000),
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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
            // Book Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    book.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

            // Author
            Text(
              "Author: ${book.author}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),

            // Genre
            Text(
              "Genre: ${book.genre}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              book.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // "Like" button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Example "like" action
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.thumb_up),
                label: Text(
                  "Like",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
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

            // "Play" button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to the PlayerScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  "Play",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
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
