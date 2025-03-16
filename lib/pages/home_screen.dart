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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
      body: CustomScrollView(
        slivers: [
          // SliverAppBar without a leading icon and with a notification button on the right.
          SliverAppBar(
            pinned: true,
            floating: false,
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            // Removed the leading property
            title: Text(
              'narratra.',
              style: TextStyle(
                fontFamily: 'NarratraFont', // Your custom font family name
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                  // Add your notification action here.
                },
              ),
            ],
          ),

          // Trending Section (Not pinned now)
          SliverPersistentHeader(
            pinned: false, // Changed pinned to false
            delegate: TrendingHeaderDelegate(
              minHeight: 280,
              maxHeight: 280,
              child: Container(
                color: const Color(0xFFC7D9DD),
                child: _TrendingSection(booksFuture: trendingBooksFuture),
              ),
            ),
          ),

          // Other categories
          SliverToBoxAdapter(
            child: CategorySection(
              title: "Uniquely Yours",
              booksFuture: recommendedBooksFuture,
            ),
          ),
          SliverToBoxAdapter(
            child: CategorySection(
              title: "Today For You",
              booksFuture: todayBooksFuture,
            ),
          ),
          SliverToBoxAdapter(
            child: CategorySection(
              title: "Free Books",
              booksFuture: freeBooksFuture,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingSection extends StatelessWidget {
  final Future<List<Book>> booksFuture;
  const _TrendingSection({required this.booksFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff000000),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading Trending',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff000000),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No books available in Trending',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff000000),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                final books = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: books.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bookinfo',
                          arguments: {'bookId': book.id},
                        );
                      },
                      child: BookCard(book: book),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
    final double categoryFontSize = title == "Trending" ? 22 : 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
          SizedBox(
            height: 250,
            child: FutureBuilder<List<Book>>(
              future: booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading $title',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff000000),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No books available in $title',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff000000),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                final books = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: books.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bookinfo',
                          arguments: {'bookId': book.id},
                        );
                      },
                      child: BookCard(book: book),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                        fit: BoxFit.cover,
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
