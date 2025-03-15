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
  bool isLiked = false;
  bool isLoading = false;
  Color? dominantColor;
  Color? textColor;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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

          if (snapshot.hasError) {
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
                    'Error loading audiobook',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_music,
                    color: Color(0xFF402e7a),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Audiobook not found',
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top section with book cover and gradient
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
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
                                : Image.asset(book.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bookmark button
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
                      const SizedBox(width: 16),
                      // Play button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/player',
                            arguments: {'bookId': book.id},
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Audiobook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              dominantColor ?? const Color(0xFF402e7a),
                          foregroundColor:
                              textColor ??
                              const Color.fromARGB(255, 214, 156, 156),
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
                      // Duration and chapters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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

                      // About section
                      Text(
                        "About this audiobook",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.description,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.6,
                        ),
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
                            child: Text(
                              book.authorDescription,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.6,
                              ),
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
          );
        },
      ),
    );
  }
}
