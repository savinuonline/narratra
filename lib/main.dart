// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/pages/bookinfo.dart';
import 'firebase_options.dart';
import 'pages/genres_selection_page.dart';
import 'pages/main_screen.dart';
import 'package:frontend/pages/auth_page.dart';
import 'package:frontend/pages/intro_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/splash_screen.dart';
import 'package:frontend/pages/media_player.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'services/book_service.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3A5EF0);
    const secondaryColor = Color(0xFF4A6EF0);
    const backgroundColor = Color(0xFFF5F7FF);
    const surfaceColor = Colors.white;

    return MaterialApp(
      title: 'Book Manager - Narratra.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          background: backgroundColor,
          surface: surfaceColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(primaryColor),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return Colors.grey[300];
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
          floatingLabelStyle: const TextStyle(color: primaryColor),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: surfaceColor,
        ),
      ),
      home: const BookManagerHome(),
      onGenerateRoute: (settings) {
        // Handle Firebase initialization and navigation after splash screen
        if (settings.name == '/auth') {
          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder(
                  future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Error initializing Firebase'),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      return const AuthPage();
                    }

                    return const SplashScreen();
                  },
                ),
          );
        }
        return null;
      },
      routes: {
        '/intro': (context) => const IntroPage(),
        '/login':
            (context) => LoginPage(
              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
            ),
        '/register':
            (context) => RegisterPage(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
        '/preferences': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return GenresSelectionPage(uid: args['uid']);
        },
        '/main': (context) => const MainScreen(),
        '/bookinfo': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BookInfoPage(bookId: args['bookId']);
        },
        '/media': (context) => MediaPlayerPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

class BookManagerHome extends StatefulWidget {
  const BookManagerHome({super.key});

  @override
  State<BookManagerHome> createState() => _BookManagerHomeState();
}

class _BookManagerHomeState extends State<BookManagerHome> {
  final BookService _bookService = BookService();
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _author = '';
  String _description = '';
  String _imageUrl = '';
  String _authorImageUrl = '';
  String _authorDescription = '';
  String _selectedGenre = "Children's literature";
  bool _isFree = false;

  // Chapter details
  final List<ChapterForm> _chapters = [];
  final List<File?> _audioFiles = [];

  void _addChapter() {
    setState(() {
      _chapters.add(ChapterForm());
      _audioFiles.add(null);
    });
  }

  void _removeChapter(int index) {
    setState(() {
      _chapters.removeAt(index);
      _audioFiles.removeAt(index);
    });
  }

  Future<void> _pickAudioFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _audioFiles[index] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Add New Book'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter a title'
                                        : null,
                            onSaved: (value) => _title = value ?? '',
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Author',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter an author'
                                        : null,
                            onSaved: (value) => _author = value ?? '',
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter a description'
                                        : null,
                            onSaved: (value) => _description = value ?? '',
                            maxLines: 3,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Book Cover Image URL',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter an image URL'
                                        : null,
                            onSaved: (value) => _imageUrl = value ?? '',
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Author Image URL',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter author image URL'
                                        : null,
                            onSaved: (value) => _authorImageUrl = value ?? '',
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Author Description',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter author description'
                                        : null,
                            onSaved:
                                (value) => _authorDescription = value ?? '',
                            maxLines: 3,
                          ),
                          DropdownButtonFormField<String>(
                            value: _selectedGenre,
                            decoration: const InputDecoration(
                              labelText: 'Genre',
                            ),
                            items:
                                _bookService.categories
                                    .map(
                                      (genre) => DropdownMenuItem(
                                        value: genre,
                                        child: Text(genre),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setDialogState(
                                  () => _selectedGenre = value!,
                                ),
                          ),
                          SwitchListTile(
                            title: const Text('Is Free?'),
                            value: _isFree,
                            onChanged:
                                (value) =>
                                    setDialogState(() => _isFree = value),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Chapters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  setDialogState(() => _addChapter());
                                },
                              ),
                            ],
                          ),
                          ..._chapters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final chapter = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Chapter ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setDialogState(
                                              () => _removeChapter(index),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: chapter.titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Chapter Title',
                                      ),
                                      validator:
                                          (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Please enter chapter title'
                                                  : null,
                                    ),
                                    TextFormField(
                                      controller: chapter.descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Chapter Description',
                                      ),
                                      validator:
                                          (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Please enter chapter description'
                                                  : null,
                                      maxLines: 2,
                                    ),
                                    TextFormField(
                                      controller: chapter.durationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Duration (in seconds)',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Please enter duration';
                                        }
                                        if (int.tryParse(value!) == null) {
                                          return 'Please enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _pickAudioFile(index),
                                      icon: const Icon(Icons.upload_file),
                                      label: Text(
                                        _audioFiles[index] != null
                                            ? 'Change Audio File'
                                            : 'Upload Audio File',
                                      ),
                                    ),
                                    if (_audioFiles[index] != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Selected: ${_audioFiles[index]!.path.split('/').last}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: _submitForm,
                      child: const Text('Add Book'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      // Validate chapters
      if (_chapters.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one chapter')),
        );
        return;
      }

      // Check if all chapters have audio files
      if (_audioFiles.any((file) => file == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload audio files for all chapters'),
          ),
        );
        return;
      }

      try {
        // Prepare chapters data
        final chaptersData =
            _chapters.asMap().entries.map((entry) {
              return {
                'title': entry.value.titleController.text,
                'description': entry.value.descriptionController.text,
                'duration': int.parse(entry.value.durationController.text),
              };
            }).toList();

        // Add book to Firebase
        final id = await _bookService.addBook(
          title: _title,
          author: _author,
          genre: _selectedGenre,
          description: _description,
          imageUrl: _imageUrl,
          authorImageUrl: _authorImageUrl,
          authorDescription: _authorDescription,
          chapters: chaptersData,
          audioFiles: _audioFiles.whereType<File>().toList(),
          isFree: _isFree,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Book added successfully with ID: $id')),
          );
          // Clear form
          setState(() {
            _chapters.clear();
            _audioFiles.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding book: $e')));
        }
      }
    }
  }

  void _showEditBookDialog(Map<String, dynamic> book) {
    String title = book['title'];
    String author = book['author'];
    String description = book['description'];
    String imageUrl = book['imageUrl'];
    String authorImageUrl = book['authorImageUrl'];
    String authorDescription = book['authorDescription'];
    String selectedGenre = book['genre'];
    bool isFree = book['isFree'] ?? false;

    // Initialize chapters and audio files from book data
    List<ChapterForm> chapters = [];
    List<File?> audioFiles = [];

    if (book['chapters'] != null) {
      for (var chapterData in book['chapters']) {
        final chapter = ChapterForm();
        chapter.titleController.text = chapterData['title'];
        chapter.descriptionController.text = chapterData['description'];
        chapter.durationController.text = chapterData['duration'].toString();
        chapters.add(chapter);
        audioFiles.add(null); // We'll need to re-upload audio files
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Edit Book'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            initialValue: title,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter a title'
                                        : null,
                            onSaved: (value) => title = value ?? '',
                          ),
                          TextFormField(
                            initialValue: author,
                            decoration: const InputDecoration(
                              labelText: 'Author',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter an author'
                                        : null,
                            onSaved: (value) => author = value ?? '',
                          ),
                          TextFormField(
                            initialValue: description,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter a description'
                                        : null,
                            onSaved: (value) => description = value ?? '',
                            maxLines: 3,
                          ),
                          TextFormField(
                            initialValue: imageUrl,
                            decoration: const InputDecoration(
                              labelText: 'Book Cover Image URL',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter an image URL'
                                        : null,
                            onSaved: (value) => imageUrl = value ?? '',
                          ),
                          TextFormField(
                            initialValue: authorImageUrl,
                            decoration: const InputDecoration(
                              labelText: 'Author Image URL',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter author image URL'
                                        : null,
                            onSaved: (value) => authorImageUrl = value ?? '',
                          ),
                          TextFormField(
                            initialValue: authorDescription,
                            decoration: const InputDecoration(
                              labelText: 'Author Description',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Please enter author description'
                                        : null,
                            onSaved: (value) => authorDescription = value ?? '',
                            maxLines: 3,
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedGenre,
                            decoration: const InputDecoration(
                              labelText: 'Genre',
                            ),
                            items:
                                _bookService.categories
                                    .map(
                                      (genre) => DropdownMenuItem(
                                        value: genre,
                                        child: Text(genre),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setDialogState(
                                  () => selectedGenre = value!,
                                ),
                          ),
                          SwitchListTile(
                            title: const Text('Is Free?'),
                            value: isFree,
                            onChanged:
                                (value) => setDialogState(() => isFree = value),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Chapters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  setDialogState(() {
                                    chapters.add(ChapterForm());
                                    audioFiles.add(null);
                                  });
                                },
                              ),
                            ],
                          ),
                          ...chapters.asMap().entries.map((entry) {
                            final index = entry.key;
                            final chapter = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Chapter ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setDialogState(() {
                                              chapters.removeAt(index);
                                              audioFiles.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: chapter.titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Chapter Title',
                                      ),
                                      validator:
                                          (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Please enter chapter title'
                                                  : null,
                                    ),
                                    TextFormField(
                                      controller: chapter.descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Chapter Description',
                                      ),
                                      validator:
                                          (value) =>
                                              value?.isEmpty ?? true
                                                  ? 'Please enter chapter description'
                                                  : null,
                                      maxLines: 2,
                                    ),
                                    TextFormField(
                                      controller: chapter.durationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Duration (in seconds)',
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Please enter duration';
                                        }
                                        if (int.tryParse(value!) == null) {
                                          return 'Please enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        try {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                                    type: FileType.audio,
                                                    allowMultiple: false,
                                                  );

                                          if (result != null) {
                                            setDialogState(() {
                                              audioFiles[index] = File(
                                                result.files.single.path!,
                                              );
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error picking file: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.upload_file),
                                      label: Text(
                                        audioFiles[index] != null
                                            ? 'Change Audio File'
                                            : 'Upload Audio File',
                                      ),
                                    ),
                                    if (audioFiles[index] != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Selected: ${audioFiles[index]!.path.split('/').last}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState!.save();

                          // Validate chapters
                          if (chapters.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please add at least one chapter',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            // Prepare chapters data
                            final chaptersData =
                                chapters.asMap().entries.map((entry) {
                                  return {
                                    'title': entry.value.titleController.text,
                                    'description':
                                        entry.value.descriptionController.text,
                                    'duration': int.parse(
                                      entry.value.durationController.text,
                                    ),
                                  };
                                }).toList();

                            // Update book in Firebase
                            await _bookService.updateBook(
                              id: book['id'],
                              genre: selectedGenre,
                              title: title,
                              author: author,
                              description: description,
                              imageUrl: imageUrl,
                              authorImageUrl: authorImageUrl,
                              authorDescription: authorDescription,
                              chapters: chaptersData,
                              audioFiles: audioFiles.whereType<File>().toList(),
                              isFree: isFree,
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Book updated successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating book: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deleteBook(String id, String genre) async {
    try {
      await _bookService.deleteBook(id, genre);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting book: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Manager')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _bookService.getAllBooksStream(),
        builder: (context, snapshot) {
          print('StreamBuilder state: ${snapshot.connectionState}');
          if (snapshot.hasData) {
            print('Number of books in UI: ${snapshot.data!.length}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('StreamBuilder error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No books added yet'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    book['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${book['author']} - ${book['genre']}${book['isFree'] ? ' (Free)' : ''}\n${book['chapterCount']} chapters • ${(book['totalDuration'] / 60).toStringAsFixed(1)} minutes',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Text(
                      book['id'],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditBookDialog(book),
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteBook(book['id'], book['genre']),
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChapterForm {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
  }
}
