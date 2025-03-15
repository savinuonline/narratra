import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class BookInfoPage extends StatefulWidget {
  final String bookId;

  const BookInfoPage({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();
  bool isLiked = false;
  bool isLoading = false;
  Color? dominantColor;
  Color? textColor;
  bool _isAppBarExpanded = true;
  bool _showAboutDescription = false;
  bool _showAuthorDescription = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isAppBarExpanded =
        _scrollController.hasClients &&
        _scrollController.offset < (MediaQuery.of(context).size.height * 0.35);
    if (isAppBarExpanded != _isAppBarExpanded) {
      setState(() {
        _isAppBarExpanded = isAppBarExpanded;
      });
    }
  }

  Future<void> _updatePaletteGenerator(String imageUrl) async {
    try {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
            NetworkImage(imageUrl),
            size: const Size(200, 300),
          );
      if (mounted) {
        setState(() {
          dominantColor =
              generator.dominantColor?.color ?? const Color(0xFF402e7a);
          textColor = generator.dominantColor?.bodyTextColor ?? Colors.white;
        });
      }
    } catch (e) {
      // If there's an error, use default colors
      if (mounted) {
        setState(() {
          dominantColor = const Color(0xFF402e7a);
          textColor = Colors.white;
        });
      }
    }
  }

  Future<void> _checkIfLiked() async {
    final userId = 'USER_ID'; // Replace with actual user ID
    final liked = await _firebaseService.isBookLiked(userId, widget.bookId);
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = 'USER_ID'; // Replace with actual user ID
      final liked = await _firebaseService.toggleBookLike(
        userId,
        widget.bookId,
      );

      if (mounted) {
        setState(() {
          isLiked = liked;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(liked ? 'Added to library' : 'Removed from library'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating library'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildCategoryIcon(String genre) {
    IconData iconData;
    switch (genre.toLowerCase()) {
      case "children's literature":
        iconData = Icons.child_care;
        break;
      case "fiction":
        iconData = Icons.auto_stories;
        break;
      case "romance":
        iconData = Icons.favorite;
        break;
      case "thriller":
        iconData = Icons.psychology;
        break;
      default:
        iconData = Icons.book;
    }
    return Icon(iconData, size: 20, color: Colors.grey[600]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Book?>(
        future: _firebaseService.getBookById(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF402e7a)),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFF402e7a),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.hasError
                        ? 'Error loading audiobook'
                        : 'Audiobook not found',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final book = snapshot.data!;
          if (dominantColor == null && book.imageUrl.startsWith('http')) {
            _updatePaletteGenerator(book.imageUrl);
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Expandable app bar with book cover
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.5,
                pinned: true,
                stretch: true,
                backgroundColor: dominantColor ?? const Color(0xFF402e7a),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          dominantColor?.withOpacity(0.8) ??
                              const Color(0xFF402e7a),
                          const Color.fromARGB(255, 238, 115, 115),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              book.imageUrl.startsWith('http')
                                  ? Image.network(
                                    book.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    book.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  title:
                      !_isAppBarExpanded
                          ? Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                actions:
                    !_isAppBarExpanded
                        ? [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: _toggleLike,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/player',
                                arguments: {'bookId': book.id},
                              );
                            },
                          ),
                        ]
                        : null,
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration section - moved up and left-aligned
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '8h 45m',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '12 Chapters',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons - repositioned
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bookmark button - moved left
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon:
                                  isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF402e7a),
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        isLiked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: const Color(0xFF402e7a),
                                      ),
                              onPressed: _toggleLike,
                            ),
                          ),

                          // Play button - moved right
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/player',
                                arguments: {'bookId': book.id},
                              );
                            },
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Listen Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  dominantColor ?? const Color(0xFF402e7a),
                              foregroundColor: textColor ?? Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Book details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Author
                          Text(
                            book.author,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Category with icon
                          Row(
                            children: [
                              _buildCategoryIcon(book.genre),
                              const SizedBox(width: 8),
                              Text(
                                book.genre,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // About section with See More button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About this audiobook",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAboutDescription =
                                        !_showAboutDescription;
                                  });
                                },
                                child: Text(
                                  _showAboutDescription
                                      ? "See Less"
                                      : "See More",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF402e7a),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            book.description,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                            maxLines: _showAboutDescription ? null : 4,
                            overflow:
                                _showAboutDescription
                                    ? null
                                    : TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 32),

                          // About Author section with See More button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About the Author",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showAuthorDescription =
                                        !_showAuthorDescription;
                                  });
                                },
                                child: Text(
                                  _showAuthorDescription
                                      ? "See Less"
                                      : "See More",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF402e7a),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (book.authorImageUrl.isNotEmpty)
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(book.authorImageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  book.authorDescription,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                    height: 1.6,
                                  ),
                                  maxLines: _showAuthorDescription ? null : 4,
                                  overflow:
                                      _showAuthorDescription
                                          ? null
                                          : TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
