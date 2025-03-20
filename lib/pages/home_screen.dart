import 'package:firebase_auth/firebase_auth.dart';
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

  const HomeScreen({Key? key, required this.user}) : super(key: key);

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
    return Container(
      // Set entire background to white
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          // SliverAppBar with white background
          SliverAppBar(
            pinned: true,
            floating: false,
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'narratra.',
              style: GoogleFonts.poppins(
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

          // Trending Section (with white background)
          SliverPersistentHeader(
            pinned: false,
            delegate: TrendingHeaderDelegate(
              minHeight: 320,
              maxHeight: 320,
              child: Container(
                color: Colors.white,
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
          // Add bottom padding to account for navigation bar
          SliverToBoxAdapter(child: SizedBox(height: 80)),
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
            style: GoogleFonts.nunito(
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
            style: GoogleFonts.nunito(
              fontSize: 20,
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
    // If the imageUrl does not start with "http" and is not an asset path (e.g., "lib/"),
    // we assume it is a filename in your Firebase Storage "Book covers" folder.
    String displayImageUrl;
    if (book.imageUrl.startsWith('lib/')) {
      displayImageUrl = book.imageUrl;
    } else if (!book.imageUrl.startsWith('http')) {
      displayImageUrl =
          "https://firebasestorage.googleapis.com/v0/b/narratradb.firebasestorage.app/o/Book%20covers%2F${Uri.encodeComponent(book.imageUrl)}?alt=media";
    } else {
      displayImageUrl = book.imageUrl;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 180,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Transform(
            // Add subtle 3D perspective
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(0.05),
            alignment: Alignment.center,
            child: Container(
              width: 125,
              height: 160,
              decoration: BoxDecoration(
                boxShadow: [
                  // Shadow on the right edge
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(5, 0),
                  ),
                  // Shadow at the bottom
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 7),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:
                    book.imageUrl.startsWith('lib/')
                        ? Image.asset(
                          book.imageUrl,
                          width: 125,
                          height: 160,
                          fit: BoxFit.cover,
                        )
                        : Image.network(
                          book.imageUrl,
                          width: 125,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ),
        ),

        // Title and author
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 132,
                child: Text(
                  book.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF000000),
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 132,
                child: Text(
                  book.author,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[700],
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
