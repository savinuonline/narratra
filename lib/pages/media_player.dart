import 'package:flutter/material.dart';
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
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
    ));
  }

  Future<void> _loadBook() async {
    try {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final bookId = args['bookId'] as String;
      final genre = args['genre'] as String;
      final initialChapterIndex = args['chapterIndex'] as int? ?? 0;

      final bookData = await _firebaseService.getBookById(bookId);
      if (bookData == null) throw Exception('Book not found');

      final book = Book.fromMap(bookData as Map<String, dynamic>, bookId);

      if (mounted) {
        setState(() {
          _book = book;
          _currentChapterIndex = initialChapterIndex;
          _isLoading = false;
        });
      }

      // Load the audio file
      await _loadChapter(initialChapterIndex);

      // Get and set the last position
      final lastPosition = await _firebaseService.getListeningProgress('USER_ID', bookId);
      if (lastPosition != null) {
        await _audioPlayer.seek(lastPosition);
      }

      // Start position tracking
      _audioPlayer.positionStream.listen((position) {
        _firebaseService.saveListeningProgress('USER_ID', bookId, position);
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading audiobook: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadChapter(int index) async {
    if (_book == null || index < 0 || index >= _book!.chapters.length) return;

    try {
      final chapter = _book!.chapters[index];
      final audioUrl = _useAlternateVoice && chapter.alternateAudioUrl.isNotEmpty
          ? chapter.alternateAudioUrl
          : chapter.audioUrl;

      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chapter: $e')),
        );
      }
    }
  }

  void _skipForward() {
    if (_audioPlayer.position + const Duration(seconds: 10) > _audioPlayer.duration!) {
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
    if (_book == null || _currentChapterIndex >= _book!.chapters.length - 1) return;
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _book == null) {
      return Scaffold(
        body: Center(
          child: Text(_errorMessage ?? 'Error loading audiobook'),
        ),
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
                      "PLAYING NOW",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasAlternateVoice)
                      IconButton(
                        icon: Icon(
                          _useAlternateVoice ? Icons.record_voice_over : Icons.voice_over_off,
                          color: Colors.white,
                        ),
                        onPressed: _toggleVoice,
                        tooltip: _useAlternateVoice ? 'Switch to Voice 1' : 'Switch to Voice 2',
                      )
                    else
                      const SizedBox(width: 48),
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
                  child: Image.network(
                    _book!.imageUrl,
                    fit: BoxFit.cover,
                  ),
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
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                      onPressed: _previousChapter,
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
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
                            icon: const Icon(Icons.play_circle_filled),
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
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                      onPressed: _skipForward,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
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
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
