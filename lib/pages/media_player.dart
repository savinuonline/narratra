import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import 'dart:ui';

class MediaPlayerPage extends StatefulWidget {
  const MediaPlayerPage({Key? key}) : super(key: key);

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Book? _book;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  bool _useAlternateVoice = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAudioSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBook();
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ),
    );
  }

  Future<void> _loadBook() async {
    try {
      print('Starting to load book...');

      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      print('Received arguments: $args');

      final bookId = args['bookId'] as String;
      print('Book ID: $bookId');

      final initialChapterIndex = args['chapterIndex'] as int? ?? 0;
      print('Initial chapter index: $initialChapterIndex');

      print('Fetching book data from Firebase...');
      final book = await _firebaseService.getBookById(bookId);
      if (book == null) {
        print('Error: Book data is null');
        throw Exception('Book not found');
      }
      print('Book data received: $book');
      print('Book details:');
      print('- Number of chapters: ${book.chapters.length}');

      if (mounted) {
        print('Setting state with book data...');
        setState(() {
          _book = book;
          _currentChapterIndex = initialChapterIndex;
          _isLoading = false;
        });
      }

      print('Loading initial chapter...');
      await _loadChapter(initialChapterIndex);

      print('Fetching last listening position...');
      final lastPosition = await _firebaseService.getListeningProgress(
        'USER_ID',
        bookId,
      );
      if (lastPosition != null) {
        print('Last position found: ${lastPosition.inSeconds} seconds');
        await _audioPlayer.seek(lastPosition);
      } else {
        print('No last position found, starting from beginning');
      }

      print('Setting up position tracking...');
      _audioPlayer.positionStream.listen((position) {
        print('Current position: ${position.inSeconds} seconds');
        _firebaseService.saveListeningProgress('USER_ID', bookId, position);
      });

      print('Book loading completed successfully');
    } catch (e, stackTrace) {
      print('Error in _loadBook:');
      print('Error message: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading audiobook: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadChapter(int index) async {
    print('Starting to load chapter $index...');

    if (_book == null) {
      print('Error: Book is null');
      return;
    }

    if (index < 0 || index >= _book!.chapters.length) {
      print(
        'Error: Invalid chapter index. Book has ${_book!.chapters.length} chapters',
      );
      return;
    }

    try {
      final chapter = _book!.chapters[index];
      print('Chapter details:');
      print('- Title: ${chapter.title}');
      print('- Duration: ${chapter.duration.inMinutes} minutes');
      print('- Primary audio URL: ${chapter.audioUrl}');
      print('- Alternate audio URL: ${chapter.alternateAudioUrl}');
      print('- Has alternate voice: ${chapter.alternateAudioUrl.isNotEmpty}');

      if (chapter.audioUrl.isEmpty) {
        throw Exception('Primary audio URL is empty');
      }

      final audioUrl =
          _useAlternateVoice && chapter.alternateAudioUrl.isNotEmpty
              ? chapter.alternateAudioUrl
              : chapter.audioUrl;

      if (audioUrl.isEmpty) {
        throw Exception('Selected audio URL is empty');
      }

      await _audioPlayer.setUrl(audioUrl);

      print('Starting playback...');
      _audioPlayer.play();
      print('Playback started');
    } catch (e, stackTrace) {
      print('Error in _loadChapter:');
      print('Error message: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chapter: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _skipForward() {
    if (_audioPlayer.position + const Duration(seconds: 10) >
        _audioPlayer.duration!) {
      _nextChapter();
    } else {
      _audioPlayer.seek(_audioPlayer.position + const Duration(seconds: 10));
    }
  }

  void _skipBackward() {
    if (_audioPlayer.position - const Duration(seconds: 10) < Duration.zero) {
      _previousChapter();
    } else {
      _audioPlayer.seek(_audioPlayer.position - const Duration(seconds: 10));
    }
  }

  void _nextChapter() {
    if (_book == null || _currentChapterIndex >= _book!.chapters.length - 1)
      return;
    setState(() {
      _currentChapterIndex++;
    });
    _loadChapter(_currentChapterIndex);
  }

  void _previousChapter() {
    if (_book == null || _currentChapterIndex <= 0) return;
    setState(() {
      _currentChapterIndex--;
    });
    _loadChapter(_currentChapterIndex);
  }

  void _toggleVoice() {
    setState(() {
      _useAlternateVoice = !_useAlternateVoice;
    });
    _loadChapter(_currentChapterIndex);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _book == null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage ?? 'Error loading audiobook')),
      );
    }

    final chapter = _book!.chapters[_currentChapterIndex];
    final hasAlternateVoice = chapter.alternateAudioUrl.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 3, 21, 46),
              const Color.fromARGB(255, 202, 218, 234),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Playing Now",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasAlternateVoice)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<bool>(
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _useAlternateVoice
                                    ? Icons.man_rounded
                                    : Icons.woman_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _useAlternateVoice ? 'Savoy' : 'Oshadi',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          tooltip: 'Select voice',
                          onSelected: (bool value) {
                            setState(() {
                              _useAlternateVoice = value;
                            });
                            _loadChapter(_currentChapterIndex);
                          },
                          itemBuilder:
                              (BuildContext context) => <PopupMenuEntry<bool>>[
                                PopupMenuItem<bool>(
                                  value: false,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.woman_rounded,
                                        color: Colors.pink,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Oshadi',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<bool>(
                                  value: true,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.man_rounded,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Savoy',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      )
                    else
                      const SizedBox(width: 60),
                  ],
                ),
              ),

              // Book Cover
              Container(
                width: 250,
                height: 250,
                margin: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(_book!.imageUrl, fit: BoxFit.cover),
                ),
              ),

              // Title and Chapter Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      _book!.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chapter ${_currentChapterIndex + 1}: ${chapter.title}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (hasAlternateVoice)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Voice ${_useAlternateVoice ? '2' : '1'}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _audioPlayer.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _previousChapter,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _skipBackward,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;

                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_circle),
                            iconSize: 64,
                            color: Colors.white,
                            onPressed: _audioPlayer.play,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.pause_circle_filled),
                            iconSize: 64,
                            color: Colors.white,
                            onPressed: _audioPlayer.pause,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _skipForward,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _nextChapter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }
}
