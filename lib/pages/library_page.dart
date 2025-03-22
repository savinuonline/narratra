import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0x3455d8),
          elevation: 0,
          title: Text(
            'My Narratra.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'My Playlists'),
              Tab(text: 'narratra. History'),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 60,
          ),
          child: Column(
          children: [
              Expanded(
                child: TabBarView(
                  children: [_SavedAudiobooksTab(), _ListeningHistoryTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedAudiobooksTab extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firebaseService.getUserLibraryStream('USER_ID'),
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
                      builder: (context) => PlaylistDetailPage(
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
                          builder: (context) => PlaylistDetailPage(
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
              child: isSvg
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
  final bool isLikedPlaylist;

  const PlaylistDetailPage({
    Key? key,
    required this.title,
    required this.books,
    required this.playlistId,
    this.isLikedPlaylist = false,
  }) : super(key: key);

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _renameController = TextEditingController();
  String _playlistTitle = '';

  @override
  void initState() {
    super.initState();
    _playlistTitle = widget.title;
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
                      'USER_ID',
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
                  backgroundColor: const Color(0xFF402e7a),
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
                    'USER_ID',
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
    final hasBooks = widget.books.isNotEmpty;
    final firstBook = hasBooks ? widget.books.first : null;

    return Scaffold(
      backgroundColor:
          Colors
              .white,
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
                                  color: const Color(0xFF402e7a),
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
                            '${widget.books.length} audiobooks',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Implement play all functionality
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
                  final book = widget.books[index];
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
                          'USER_ID',
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
                                '/player',
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
                }, childCount: widget.books.length),
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

class _ListeningHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('lib/images/history.png', width: 84, height: 84),
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
