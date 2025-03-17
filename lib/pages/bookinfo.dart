import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import 'dart:ui';
import 'category_page.dart';

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
  bool isBookmarked = false;
  bool isLoading = false;
  bool isBookmarkLoading = false;
  Color? dominantColor;
  Color? textColor;
  double _scrollOffset = 0.0;
  bool _showAboutDescription = false;
  bool _showAuthorDescription = false;
  Book? _book;
  bool _isLoadingBook = true;
  String? _errorMessage;
  final TextEditingController _playlistNameController = TextEditingController();

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
    _playlistNameController.dispose();
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
    final bookmarked = await _firebaseService.isBookBookmarked(
      userId,
      widget.bookId,
    );
    if (mounted) {
      setState(() {
        isLiked = liked;
        isBookmarked = bookmarked;
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

        // Update like count in Firebase
        if (liked) {
          await _firebaseService.incrementBookLikeCount(widget.bookId);
        } else {
          await _firebaseService.decrementBookLikeCount(widget.bookId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              liked ? 'Added to favorites' : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating favorites'),
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

  Future<void> _showCreatePlaylistDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: _firebaseService.getUserLibraryStream('USER_ID'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final playlists = List<Map<String, dynamic>>.from(
              snapshot.data?['playlists'] ?? [],
            );

            return AlertDialog(
              title: Text(
                'Add to Playlist',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Create New Playlist Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showNewPlaylistDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Create New Playlist',
                        style: GoogleFonts.poppins(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          198,
                          182,
                          182,
                        ),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    if (playlists.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Your Playlists',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...playlists.map(
                        (playlist) => ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  dominantColor?.withOpacity(0.1) ??
                                  Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.playlist_play,
                              color: dominantColor ?? Colors.grey,
                            ),
                          ),
                          title: Text(
                            playlist['name'],
                            style: GoogleFonts.poppins(),
                          ),
                          onTap: () async {
                            await _firebaseService.addBookToPlaylist(
                              'USER_ID',
                              playlist['id'],
                              widget.bookId,
                            );
                            if (mounted) {
                              setState(() => isBookmarked = true);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added to ${playlist['name']}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showNewPlaylistDialog() async {
    _playlistNameController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Create New Playlist',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _playlistNameController,
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
              onPressed: () {
                Navigator.pop(context);
                _playlistNameController.clear();
              },
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _playlistNameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a playlist name'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                _createPlaylist(name);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: dominantColor),
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

  Future<void> _createPlaylist(String playlistName) async {
    if (isBookmarkLoading) return;

    setState(() {
      isBookmarkLoading = true;
    });

    try {
      final userId = 'USER_ID'; // Replace with actual user ID
      final playlistId = await _firebaseService.createPlaylist(
        userId,
        playlistName,
        widget.bookId,
      );

      if (mounted && playlistId.isNotEmpty) {
        setState(() {
          isBookmarked = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to playlist: $playlistName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error creating playlist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isBookmarkLoading = false;
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

    // Calculate progress for the fixed action buttons
    final boxProgress = ((_scrollOffset - (threshold * 1.1)) /
            (threshold * 0.5))
        .clamp(0.0, 1.0);

    if (_isLoadingBook) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 0, 0, 0),
            ),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Bookmark (Playlist) button
        Container(
          width: 50,
          height: 50,
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
                isBookmarkLoading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    )
                    : Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 28,
                    ),
            onPressed: _showCreatePlaylistDialog,
          ),
        ),

        const SizedBox(width: 12),

        // Like (Heart) button
        Container(
          width: 50,
          height: 50,
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
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    )
                    : Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      color:
                          isLiked
                              ? Colors.red
                              : const Color.fromARGB(255, 0, 0, 0),
                      size: 28,
                    ),
            onPressed: _toggleLike,
          ),
        ),

        const SizedBox(width: 75),

        // Listen Now button
        SizedBox(
          width: 160,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                collapsedHeight: kToolbarHeight,
                pinned: true,
                stretch: true,
                floating: false,
                snap: false,
                backgroundColor:
                    dominantColor ?? const Color.fromARGB(255, 124, 114, 241),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showTitle ? 1.0 : 0.0,
                  child:
                      showTitle
                          ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
                                      const Color.fromARGB(255, 4, 18, 69),
                                  (dominantColor != null
                                          ? HSLColor.fromColor(
                                            dominantColor!,
                                          ).withLightness(0.8).toColor()
                                          : const Color.fromARGB(255, 239, 202, 182))
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
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                    Text(
                      book.title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.author,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CategoryPage(genre: book.genre),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: dominantColor ?? const Color(0xFF402e7a),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                _getCategoryIcon(book.genre),
                                width: 16,
                                height: 16,
                                color: dominantColor ?? Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                book.genre,
                                style: GoogleFonts.poppins(
                                  color:
                                      dominantColor ?? const Color(0xFF402e7a),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
          Positioned(
            top: _calculateButtonPosition(context),
            left: 0,
            right: 0,
            child: _buildActionButtonsContainer(actionButtons, boxProgress),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsContainer(
    Widget actionButtons,
    double boxProgress,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10 * boxProgress,
          sigmaY: 10 * boxProgress,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color:
                dominantColor?.withOpacity(0.95 * boxProgress) ??
                const Color.fromARGB(
                  255,
                  252,
                  252,
                  252,
                ).withOpacity(0.95 * boxProgress),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 * boxProgress),
                blurRadius: 4 * boxProgress,
                offset: Offset(0, 2 * boxProgress),
              ),
            ],
          ),
          child: actionButtons,
        ),
      ),
    );
  }

  double _calculateButtonPosition(BuildContext context) {
    final expandedHeight = MediaQuery.of(context).size.height * 0.5;
    final threshold =
        (expandedHeight - kToolbarHeight - MediaQuery.of(context).padding.top) *
        0.85;
    0.9;
    final minPosition =
        MediaQuery.of(context).padding.top + kToolbarHeight + 20;
    final maxPosition = expandedHeight - 20;

    if (_scrollOffset <= 0) {
      // At the top of the page
      return maxPosition;
    } else if (_scrollOffset >= threshold) {
      return minPosition;
    } else {
      return maxPosition - _scrollOffset;
    }
  }
}
