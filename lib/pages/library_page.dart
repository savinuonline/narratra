import 'package:flutter/material.dart';
import 'package:frontend/models/user_progress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import 'package:frontend/components/book_card.dart';
import 'package:frontend/components/recent_book_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  List<Book> _continuePlayingBooks = [];
  List<Book> _likedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserBooks();
    print(
      "CURRENT USER ID: ${FirebaseAuth.instance.currentUser?.uid}",
    ); // Debug user ID
  }

  Future<void> _loadUserBooks() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's progress
      final userProgress = await _firebaseService.getUserProgress(_userId!);
      print("USER PROGRESS: ${userProgress.inProgressBooks}"); // Debug
      print("USER ID BEING USED: $_userId"); // Debug

      // Get books in progress - Fix for nullable Book values
      final inProgressBooksWithNulls = await Future.wait(
        userProgress.inProgressBooks.map((bookId) async {
          final book = await _firebaseService.getBookById(bookId);
          // Return either the book or an empty Book object to satisfy the type requirements
          return book ?? Book.empty();
        }),
      );
      final inProgressBooks =
          inProgressBooksWithNulls
              .where((book) => book.id.isNotEmpty) // Filter out empty books
              .toList();
      print("IN PROGRESS BOOKS: $inProgressBooks"); // Debug

      // Get liked books
      final liked = await _firebaseService.getLikedBooks(_userId!);
      print("LIKED BOOKS: $liked"); // Debug

      setState(() {
        _continuePlayingBooks = inProgressBooks;
        _likedBooks = liked;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR LOADING BOOKS: $e"); // Debug
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3dc2ec),
        elevation: 0,
        title: Text(
          'My Narratra.',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // My Playlists section with light blue background
                    Container(
                      color: const Color(0xFF3dc2ec),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        top: 10,
                      ),
                      child: Text(
                        'Playlists',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Continue Playing section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Playing',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          StreamBuilder<UserProgress>(
                            stream:
                                FirebaseAuth.instance.currentUser != null
                                    ? _firebaseService.getUserProgressStream(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    )
                                    : Stream.value(
                                      UserProgress(
                                        userId: '',
                                        inProgressBooks: [],
                                        completedBooks: [],
                                        lastUpdated: DateTime.now(),
                                      ),
                                    ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final userProgress = snapshot.data;

                              if (userProgress == null ||
                                  userProgress.inProgressBooks.isEmpty) {
                                // Show placeholder when no books in progress
                                return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/main');
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF3dc2ec,
                                        ).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF3dc2ec,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.play_circle_outline,
                                            color: const Color(0xFF3dc2ec),
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Nothing in progress',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Start listening to an audiobook',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Show StreamBuilder for book data for in-progress books
                              return FutureBuilder<List<Book>>(
                                future: Future.wait(
                                  userProgress.inProgressBooks.map(
                                    (bookId) => _firebaseService
                                        .getBookById(bookId)
                                        .then((book) => book ?? Book.empty()),
                                  ),
                                ),
                                builder: (context, booksSnapshot) {
                                  if (!booksSnapshot.hasData) {
                                    return const Center(
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final books =
                                      booksSnapshot.data
                                          ?.where((book) => book.id.isNotEmpty)
                                          .toList() ??
                                      [];

                                  if (books.isEmpty) {
                                    // This handles the case where book IDs exist but the books can't be loaded
                                    return const SizedBox(
                                      height: 0,
                                    ); // Hide section completely
                                  }

                                  return SizedBox(
                                    height: 130,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: books.length,
                                      itemBuilder: (context, index) {
                                        final book = books[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 15,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/media',
                                                arguments: {'bookId': book.id},
                                              );
                                            },
                                            child: SizedBox(
                                              width: 250,
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.network(
                                                      book.imageUrl,
                                                      width: 80,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 80,
                                                          height: 120,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          book.title,
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          book.author,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .timer_outlined,
                                                              size: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[500],
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            FutureBuilder<
                                                              Duration?
                                                            >(
                                                              future: _firebaseService
                                                                  .getListeningProgress(
                                                                    FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            ?.uid ??
                                                                        '',
                                                                    book.id,
                                                                  ),
                                                              builder: (
                                                                context,
                                                                progressSnapshot,
                                                              ) {
                                                                if (!progressSnapshot
                                                                    .hasData) {
                                                                  return Text(
                                                                    'Loading...',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .grey[500],
                                                                    ),
                                                                  );
                                                                }

                                                                final progress =
                                                                    progressSnapshot
                                                                        .data;
                                                                final totalDuration =
                                                                    book.totalDuration;

                                                                if (progress ==
                                                                    null) {
                                                                  return Text(
                                                                    'Just started',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .grey[500],
                                                                    ),
                                                                  );
                                                                }

                                                                // Calculate remaining time
                                                                final remainingSeconds =
                                                                    totalDuration
                                                                        .inSeconds -
                                                                    progress
                                                                        .inSeconds;
                                                                if (remainingSeconds <=
                                                                    0) {
                                                                  return Text(
                                                                    'Completed',
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          Colors
                                                                              .grey[500],
                                                                    ),
                                                                  );
                                                                }

                                                                final remainingMinutes =
                                                                    remainingSeconds ~/
                                                                    60;
                                                                final displayMinutes =
                                                                    remainingMinutes %
                                                                    60;
                                                                final displayHours =
                                                                    remainingMinutes ~/
                                                                    60;

                                                                final timeLeftText =
                                                                    displayHours >
                                                                            0
                                                                        ? '${displayHours}h ${displayMinutes}m left'
                                                                        : '${displayMinutes}m left';

                                                                return Text(
                                                                  timeLeftText,
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .grey[500],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Liked Audiobooks section
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liked Audiobooks',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          StreamBuilder<List<Book>>(
                            stream:
                                FirebaseAuth.instance.currentUser != null
                                    ? _firebaseService.getLikedBooksAsStream(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    )
                                    : Stream.value([]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final likedBooks = snapshot.data ?? [];

                              if (likedBooks.isEmpty) {
                                // Show card with heart icon if no liked books
                                return InkWell(
                                  onTap: () {
                                    // Navigate to explore tab to find books to like
                                    Navigator.pushNamed(context, '/main');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'No liked audiobooks yet',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'Explore books to like',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PlaylistDetailPage(
                                            title: 'My Liked Audiobooks',
                                            books: likedBooks,
                                            playlistId: 'liked',
                                            isLikedPlaylist: true,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          if (likedBooks.isNotEmpty &&
                                              likedBooks[0].imageUrl.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                likedBooks[0].imageUrl,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.red[50],
                                                    child: const Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                      size: 30,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),

                                          if (likedBooks.length > 1)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  "${likedBooks.length}",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'My Liked Audiobooks',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "${likedBooks.length} audiobook${likedBooks.length != 1 ? 's' : ''}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // User Playlists section
                    StreamBuilder<Map<String, dynamic>>(
                      stream: _firebaseService.getUserLibraryStream(
                        _userId ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final data = snapshot.data ?? {};
                        final List<Map<String, dynamic>> playlists =
                            List<Map<String, dynamic>>.from(
                              data['playlists'] ?? [],
                            );

                        if (playlists.isEmpty) {
                          return const SizedBox.shrink(); // Don't show anything if no playlists
                        }

                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Playlists',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Column(
                                children:
                                    playlists.map((playlist) {
                                      List<dynamic> bookIds =
                                          playlist['books'] ?? [];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => PlaylistDetailPage(
                                                      title: playlist['name'],
                                                      books: [],
                                                      bookIds:
                                                          List<String>.from(
                                                            bookIds,
                                                          ),
                                                      playlistId:
                                                          playlist['id'] ?? '',
                                                      isLikedPlaylist: false,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF3dc2ec,
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.playlist_play,
                                                    color: Color(0xFF3dc2ec),
                                                    size: 30,
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Text(
                                                    playlist['name'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.chevron_right,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 15),
                              // Add playlist button
                              InkWell(
                                onTap: () {
                                  _showCreatePlaylistDialog(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF3dc2ec),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        color: Color(0xFF3dc2ec),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create New Playlist',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF3dc2ec),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final TextEditingController playlistNameController =
        TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Create New Playlist',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: playlistNameController,
            decoration: InputDecoration(
              hintText: 'Enter playlist name',
              hintStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = playlistNameController.text.trim();
                if (name.isNotEmpty) {
                  try {
                    await _firebaseService.createPlaylist(
                      _userId ?? '',
                      name,
                      '',
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Playlist "$name" created'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating playlist: $e'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3dc2ec),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(dynamic durationOrSeconds) {
    int hours;
    int minutes;

    if (durationOrSeconds is Duration) {
      hours = durationOrSeconds.inHours;
      minutes = durationOrSeconds.inMinutes.remainder(60);
    } else if (durationOrSeconds is int) {
      hours = durationOrSeconds ~/ 3600;
      minutes = (durationOrSeconds % 3600) ~/ 60;
    } else {
      return "0min"; // Default
    }

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

class _SavedAudiobooksTab extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firebaseService.getUserLibraryStream(_userId ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading library: ${snapshot.error}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        }

        final data = snapshot.data ?? {};
        final List<Book> likedBooks = List<Book>.from(data['likedBooks'] ?? []);
        final List<Map<String, dynamic>> playlists =
            List<Map<String, dynamic>>.from(data['playlists'] ?? []);

        if (likedBooks.isEmpty && playlists.isEmpty) {
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

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Liked Audiobooks Section
            if (likedBooks.isNotEmpty) ...[
              Text(
                'Liked Audiobooks',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _LibraryFolder(
                title: 'My Liked Audiobooks',
                icon: Icons.favorite_sharp,
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PlaylistDetailPage(
                            title: 'Liked Audiobooks',
                            books: likedBooks,
                            playlistId: 'liked',
                            isLikedPlaylist: true,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // User Playlists Section
            if (playlists.isNotEmpty) ...[
              Text(
                'My Playlists',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...playlists.map((playlist) {
                final List<Book> playlistBooks = List<Book>.from(
                  playlist['books'] ?? [],
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LibraryFolder(
                    title: playlist['name'],
                    icon: 'assets/icons/playlist.svg',
                    color: Colors.blue,
                    isSvg: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PlaylistDetailPage(
                                title: playlist['name'],
                                books: playlistBooks,
                                playlistId: playlist['id'] ?? '',
                                isLikedPlaylist: false,
                              ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}

class _LibraryFolder extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSvg;

  const _LibraryFolder({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSvg = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  isSvg
                      ? SvgPicture.asset(
                        icon,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      )
                      : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(221, 0, 0, 0),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class PlaylistDetailPage extends StatefulWidget {
  final String title;
  final String playlistId;
  final List<Book> books;
  final List<String>? bookIds;
  final bool isLikedPlaylist;

  const PlaylistDetailPage({
    Key? key,
    required this.title,
    required this.books,
    required this.playlistId,
    this.bookIds,
    this.isLikedPlaylist = false,
  }) : super(key: key);

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _renameController = TextEditingController();
  String _playlistTitle = '';
  bool _isLoading = false;
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _playlistTitle = widget.title;
    _books = widget.books;

    // Load books from IDs if provided
    if (widget.bookIds != null && widget.bookIds!.isNotEmpty) {
      _loadBooksFromIds();
    }
  }

  Future<void> _loadBooksFromIds() async {
    if (widget.bookIds == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final loadedBooks = await Future.wait(
        widget.bookIds!.map((id) => _firebaseService.getBookById(id)),
      );

      setState(() {
        _books =
            loadedBooks.where((book) => book != null).cast<Book>().toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  Future<void> _showRenameDialog() async {
    _renameController.text = _playlistTitle;
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Rename Playlist',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: _renameController,
              decoration: InputDecoration(
                hintText: 'Enter new playlist name',
                hintStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = _renameController.text.trim();
                  if (newName.isNotEmpty) {
                    await _firebaseService.renamePlaylist(
                      FirebaseAuth.instance.currentUser?.uid ?? '',
                      widget.playlistId,
                      newName,
                    );
                    if (mounted) {
                      setState(() => _playlistTitle = newName);
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 178, 242),
                ),
                child: Text(
                  'Rename',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Playlist',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete this playlist?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _firebaseService.deletePlaylist(
                    FirebaseAuth.instance.currentUser?.uid ?? '',
                    widget.playlistId,
                  );
                  if (mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to library
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_playlistTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasBooks = _books.isNotEmpty;
    final firstBook = hasBooks ? _books.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 60,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background:
                    hasBooks
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'lib/images/default_cover.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color.fromARGB(
                                    255,
                                    62,
                                    169,
                                    222,
                                  ),
                                  child: Icon(
                                    Icons.playlist_play,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                        : Container(
                          color: const Color(0xFF402e7a),
                          child: Icon(
                            Icons.playlist_play,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                title: Text(
                  _playlistTitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!widget.isLikedPlaylist) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _showRenameDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _confirmDelete,
                  ),
                ],
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasBooks) ...[
                      Row(
                        children: [
                          Text(
                            '${_books.length} audiobooks',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to media player with the first book
                              if (_books.isNotEmpty) {
                                Navigator.pushNamed(
                                  context,
                                  '/media',
                                  arguments: {
                                    'bookId': _books.first.id,
                                    'playlist':
                                        _books.map((book) => book.id).toList(),
                                  },
                                );
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'Play All',
                              style: GoogleFonts.poppins(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF402e7a),
                              foregroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            if (hasBooks)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = _books[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Dismissible(
                      key: Key(book.id),
                      direction:
                          widget.isLikedPlaylist
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await _firebaseService.removeBookFromPlaylist(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                          widget.playlistId,
                          book.id,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 60,
                              height: 80,
                              child:
                                  book.imageUrl.isNotEmpty
                                      ? book.imageUrl.startsWith('http')
                                          ? Image.network(
                                            book.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                          )
                                          : Image.asset(
                                            book.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.book,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                          )
                                      : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.book,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                            ),
                          ),
                          title: Text(
                            book.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            book.author,
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.play_circle_outline,
                              size: 32,
                              color: Color(0xFF402e7a),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/media',
                                arguments: {'bookId': book.id},
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/bookinfo',
                              arguments: {'bookId': book.id},
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }, childCount: _books.length),
              )
            else
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.playlist_play,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No audiobooks in this playlist',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
