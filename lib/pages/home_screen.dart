import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

// A custom delegate to control the Trending section header
class TrendingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  TrendingHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant TrendingHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

class HomeScreen extends StatefulWidget {
  final UserModel user;

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

  @override
  void initState() {
    super.initState();
    trendingBooksFuture = _firebaseService.getTrendingBooks();
    recommendedBooksFuture = _firebaseService.getRecommendedBooks(
      widget.user.uid,
    );
    todayBooksFuture = _firebaseService.getTodayForYouBooks();
    freeBooksFuture = _firebaseService.getFreeBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed bottomNavigationBar and navigation-related code
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              CategorySection(
                title: "Trending",
                booksFuture: trendingBooksFuture,
              ),
              CategorySection(
                title: "Uniquely Yours",
                booksFuture: recommendedBooksFuture,
              ),
              CategorySection(
                title: "Today For You",
                booksFuture: todayBooksFuture,
              ),
              CategorySection(
                title: "Free Books",
                booksFuture: freeBooksFuture,
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


}

class CategorySection extends StatelessWidget {
  final String title;
  final Future<List<Book>> booksFuture;

  const CategorySection({
    super.key,
    required this.title,
    required this.booksFuture,
  });

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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/bookinfo',
                        arguments: {'bookId': book.id}, // pass the book ID
                      );
                    },
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

  const BookCard({super.key, required this.book});

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
            color: const Color(0xffc7d9dd),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF97C5ED),
                blurRadius: 4,
                offset: Offset(6, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child:
                  book.imageUrl.startsWith('lib/')
                      ? Image.asset(
                        book.imageUrl,
                        width: 130,
                        height: 170,
                        alignment: const Alignment(5.0, -0.2),
                        fit: BoxFit.cover, // Keep proportions
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
        SizedBox(
          width: 150.0,
          child: Text(
            book.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF000000),
            ),
            maxLines: 1,
            textAlign: TextAlign.left,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Author
        SizedBox(
          width: 150.0,
          child: Text(
            book.author,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF000000),
            ),
            maxLines: 2,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
