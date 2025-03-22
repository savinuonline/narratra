import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/user_model.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../widgets/skeleton_loading.dart';

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

class CustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
      decelerationRate: ScrollDecelerationRate.fast,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onHomeIconTap;

  const HomeScreen({
    Key? key,
    required this.user,
    required this.onHomeIconTap,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Book>> trendingBooksFuture;
  late Future<List<Book>> recommendedBooksFuture;
  late Future<List<Book>> todayBooksFuture;
  late Future<List<Book>> freeBooksFuture;

  @override
  void initState() {
    super.initState();
    print('Initializing HomeScreen with user ID: ${widget.user.uid}');
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      trendingBooksFuture = _firebaseService.getTrendingBooks();
      recommendedBooksFuture = _firebaseService.getRecommendedBooks(widget.user.uid);
      todayBooksFuture = _firebaseService.getTodayForYouBooks();
      freeBooksFuture = _firebaseService.getFreeBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
                decelerationRate: ScrollDecelerationRate.fast,
              ),
              slivers: [
                // Transparent space for AppBar
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).padding.top + 55),
                ),

                // Trending Section
                SliverToBoxAdapter(
                  child: Container(
                    height: 320,
                    color: Colors.white,
                    child: _TrendingSection(booksFuture: trendingBooksFuture),
                  ),
                ),

                // Other sections
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
                // Add bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),

          // Blurred AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).padding.top + 65,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  color: Colors.white.withOpacity(0.8),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
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
                ),
              ),
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
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trending",
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff000000),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
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

  Widget _buildSkeletonLoading() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoading(width: 140, height: 180, borderRadius: 15),
            const SizedBox(height: 12),
            SkeletonLoading(width: 100, height: 16, borderRadius: 4),
            const SizedBox(height: 4),
            SkeletonLoading(width: 80, height: 14, borderRadius: 4),
          ],
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff000000),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: FutureBuilder<List<Book>>(
              future: booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeletonLoading();
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

  Widget _buildSkeletonLoading() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoading(width: 140, height: 180, borderRadius: 15),
            const SizedBox(height: 12),
            SkeletonLoading(width: 100, height: 16, borderRadius: 4),
            const SizedBox(height: 4),
            SkeletonLoading(width: 80, height: 14, borderRadius: 4),
          ],
        );
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 180,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              book.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
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
                    fontSize: 14,
                    color: const Color(0xFF000000),
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 132,
                child: Text(
                  book.author,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
