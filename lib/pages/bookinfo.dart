import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
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
      final liked = await _firebaseService.toggleBookLike(userId, widget.bookId);
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1E1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Book?>(
        future: _firebaseService.getBookById(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading audiobook: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Audiobook not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final book = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover and actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover
                      Container(
                        width: 150,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: book.imageUrl.startsWith('http')
                              ? Image.network(book.imageUrl, fit: BoxFit.cover)
                              : Image.asset(book.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Action buttons
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Icon(
                                          isLiked ? Icons.bookmark : Icons.bookmark_border,
                                          color: Colors.white,
                                        ),
                                  onPressed: _toggleLike,
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/player',
                                  arguments: {'bookId': book.id},
                                );
                              },
                              icon: const Icon(Icons.headphones),
                              label: const Text('Listen Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF402e7a),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Book details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Narrated by ${book.author}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF402e7a),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              book.genre,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '8h 45m',  // You might want to add this to your Book model
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "About this audiobook",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[300],
                          height: 1.6,
                        ),
                      ),
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
