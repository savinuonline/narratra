import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  double _scrollOffset = 0.0;
  bool _showAboutDescription = false;
  bool _showAuthorDescription = false;
  Book? _book;
  bool _isLoadingBook = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBook();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadBook() async {
    try {
      final book = await _firebaseService.getBookById(widget.bookId);
      if (mounted) {
        setState(() {
          _book = book;
          _isLoadingBook = false;
          if (book != null && book.imageUrl.startsWith('http')) {
            _updatePaletteGenerator(book.imageUrl);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading audiobook';
          _isLoadingBook = false;
        });
      }
    }
    await _checkIfLiked();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
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
          // Get the dominant color or use a vibrant/muted color if available
          dominantColor =
              generator.dominantColor?.color ??
              generator.vibrantColor?.color ??
              generator.mutedColor?.color ??
              const Color(0xFF402e7a);
          textColor = generator.dominantColor?.bodyTextColor ?? Colors.white;
        });
      }
    } catch (e) {
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

  String _getCategoryIcon(String genre) {
    String svg;
    switch (genre.toLowerCase()) {
      case "children's literature":
        svg = 'lib/images/children_lit.svg';
        break;
      case "fiction":
        svg = 'lib/images/fiction.svg';
        break;
      case "romance":
        svg = 'lib/images/romance.svg';
        break;
      case "thriller":
        svg = 'lib/images/thriller.svg';
        break;
      default:
        svg = 'lib/images/book.png';
    }
    return svg;
  }

  @override
  Widget build(BuildContext context) {
    final threshold =
        MediaQuery.of(context).size.height * 0.35 - kToolbarHeight;
    final showTitle = _scrollOffset > threshold;

    if (_isLoadingBook) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF402e7a)),
          ),
        ),
      );
    }

    if (_errorMessage != null || _book == null) {
      return Scaffold(
        body: Center(
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
                _errorMessage ?? 'Audiobook not found',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Book is loaded and available
    final book = _book!;

    // Store action buttons in a variable to reuse them
    final actionButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 56,
          height: 80,
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
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    )
                    : Icon(
                      isLiked
                          ? Icons.bookmark
                          : Icons.bookmark_outline_outlined,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 35,
                    ),
            onPressed: _toggleLike,
          ),
        ),
        const SizedBox(width: 120),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/player',
                arguments: {'bookId': book.id},
              );
            },
            icon: const Icon(Icons.play_circle_fill, size: 30),
            label: Text(
              'Listen Now',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  dominantColor ?? const Color.fromARGB(255, 249, 249, 249),
              foregroundColor: textColor ?? const Color.fromARGB(255, 0, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.5,
                pinned: true,
                stretch: true,
                floating: false,
                snap: false,
                backgroundColor: dominantColor ?? const Color(0xFF402e7a),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showTitle ? 1.0 : 0.0,
                  child:
                      showTitle
                          ? Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                          : null,
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final scrollExtent =
                        MediaQuery.of(context).size.height * 0.5 -
                        kToolbarHeight;
                    final scrollPosition =
                        (constraints.maxHeight - kToolbarHeight) / scrollExtent;
                    final adjustedPosition = scrollPosition.clamp(0.0, 1.0);

                    return FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  dominantColor?.withOpacity(0.9) ??
                                      const Color(0xFF402e7a),
                                  (dominantColor != null
                                          ? HSLColor.fromColor(
                                            dominantColor!,
                                          ).withLightness(0.8).toColor()
                                          : const Color.fromARGB(
                                            255,
                                            31,
                                            43,
                                            45,
                                          ))
                                      .withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: adjustedPosition,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * adjustedPosition),
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Add space for fixed action buttons when they become "fixed"
              showTitle
                  ? SliverToBoxAdapter(child: SizedBox(height: 120))
                  : SliverToBoxAdapter(child: Container()),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const SizedBox(height: 20),
                    // Duration and chapters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '8h 45m',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.nunitoSans(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 15,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Text(
                            '12 Chapters',
                            style: GoogleFonts.nunitoSans(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title
                    Text(
                      book.title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Author
                    Text(
                      book.author,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category with icon
                    Row(
                      children: [
                        SvgPicture.asset(
                          _getCategoryIcon(book.genre),
                          width: 20,
                          height: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          book.genre,
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // About section
                    Text(
                      "About",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAboutDescription = !_showAboutDescription;
                            });
                          },
                          child: Text(
                            _showAboutDescription ? 'See less' : 'See more',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: dominantColor ?? const Color(0xFF402e7a),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // About Author section
                    Text(
                      "About the Author",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
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
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAuthorDescription =
                                        !_showAuthorDescription;
                                  });
                                },
                                child: Text(
                                  _showAuthorDescription
                                      ? 'See less'
                                      : 'See more',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color:
                                        dominantColor ??
                                        const Color(0xFF402e7a),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),

          // The buttons will now be properly positioned and scroll with content
          Positioned(
            top: _calculateButtonPosition(context),
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color:
                    showTitle
                        ? (dominantColor?.withOpacity(0.95) ??
                            const Color(0xFF402e7a).withOpacity(0.95))
                        : Colors.transparent,
                boxShadow:
                    showTitle
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: actionButtons,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateButtonPosition(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.5;
    final threshold =
        expandedHeight - kToolbarHeight - MediaQuery.of(context).padding.top;
    final minPosition = MediaQuery.of(context).padding.top + kToolbarHeight;
    final maxPosition =
        expandedHeight - 32; // Adjusted to position buttons slightly higher

    if (_scrollOffset <= 0) {
      // At the top of the page
      return maxPosition;
    } else if (_scrollOffset >= threshold) {
      // Scrolled enough to fix to top
      return minPosition;
    } else {
      // In between - buttons should move with scroll
      return maxPosition - _scrollOffset;
    }
  }
}
