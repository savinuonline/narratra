import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(199, 217, 221, 1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'My Narratra.',
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF402e7a),
            labelColor: const Color.fromARGB(255, 0, 0, 0),
            unselectedLabelColor: const Color.fromARGB(255, 58, 65, 65),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'My Playlists'),
              Tab(text: 'narratra. History'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [_SavedAudiobooksTab(), _ListeningHistoryTab()],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SavedAudiobooksTab extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: _firebaseService.getLikedBooksStream(
        'USER_ID',
      ), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading audiobooks: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/empty_playlist.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  'It seems pretty empty here...',
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some audiobooks to make them your own!!',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: books.length,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                book.imageUrl.startsWith('http')
                                    ? Image.network(
                                      book.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                    : Image.asset(
                                      book.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                          ),
                        ),
                        // Play icon overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    book.title,
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Narrator
                  Text(
                    '${book.author}',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ListeningHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(
            'Listening history coming soon',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
