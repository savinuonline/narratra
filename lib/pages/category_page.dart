import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class CategoryPage extends StatelessWidget {
  final String genre;
  final FirebaseService _firebaseService = FirebaseService();

  CategoryPage({Key? key, required this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            backgroundColor: const Color(0xFF402e7a),
            centerTitle: true,
            pinned: true,
            elevation: 0,
            title: Text(
              genre,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(top: 60),
                alignment: const Alignment(0.2, 0),
                color: const Color.fromARGB(255, 2, 140, 171),
                child: Text(
                  'Explore more books in $genre',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ), // Padding for title
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ), // White back button
              onPressed: () => Navigator.pop(context),
            ),
          ),

          StreamBuilder<List<Book>>(
            stream: _firebaseService.getBooksByGenre(genre),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF402e7a),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading books',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final books = snapshot.data ?? [];

              if (books.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No books found in this category',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final book = books[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/bookinfo',
                          arguments: {'bookId': book.id},
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book cover with 3D effect
                            Expanded(
                              flex: 4,
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: Transform(
                                  transform:
                                      Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateY(0.05),
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(4, 0),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                          spreadRadius: -2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          book.imageUrl.isNotEmpty
                                              ? book.imageUrl.startsWith('http')
                                                  ? Image.network(
                                                    book.imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Icon(
                                                          Icons.book,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 40,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  : Image.asset(
                                                    book.imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Icon(
                                                          Icons.book,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 40,
                                                        ),
                                                      );
                                                    },
                                                  )
                                              : Center(
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.grey[400],
                                                  size: 40,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Book details
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      book.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${book.likeCount}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),

                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: books.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
