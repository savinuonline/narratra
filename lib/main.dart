import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/book_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3A5EF0);
    const secondaryColor = Color(0xFF4A6EF0);
    const backgroundColor = Color(0xFFF5F7FF);
    const surfaceColor = Colors.white;

    return MaterialApp(
      title: 'Book Manager - Narratra.',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          tileColor: surfaceColor,
        ),
      ),
      home: const BookManagerHome(),
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
  String _audioUrl = '';
  String _selectedGenre = "Children's literature";
  bool _isFree = false;

  void _showAddBookDialog() {
    bool localIsFree = _isFree;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Book'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
                    onSaved: (value) => _title = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an author'
                        : null,
                    onSaved: (value) => _author = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a description'
                        : null,
                    onSaved: (value) => _description = value ?? '',
                    maxLines: 3,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an image URL'
                        : null,
                    onSaved: (value) => _imageUrl = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Audio URL'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an audio URL'
                        : null,
                    onSaved: (value) => _audioUrl = value ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    decoration: const InputDecoration(labelText: 'Genre'),
                    items: _bookService.categories
                        .map((genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGenre = value!),
                  ),
                  SwitchListTile(
                    title: const Text('Is Free?'),
                    value: localIsFree,
                    onChanged: (value) {
                      setDialogState(() => localIsFree = value);
                      setState(
                          () => _isFree = value); // Also update parent state
                    },
                  ),
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
              onPressed: () {
                // Update the _isFree variable before submitting
                setState(() => _isFree = localIsFree);
                _submitForm();
              },
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
      try {
        final id = await _bookService.addBook(
          title: _title,
          author: _author,
          genre: _selectedGenre,
          description: _description,
          imageUrl: _imageUrl,
          audioUrl: _audioUrl,
          isFree: _isFree,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Book added successfully with ID: $id')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding book: $e')),
          );
        }
      }
    }
  }

  void _showEditBookDialog(Map<String, dynamic> book) {
    String title = book['title'];
    String author = book['author'];
    String description = book['description'];
    String imageUrl = book['imageUrl'];
    String audioUrl = book['audioUrl'];
    String selectedGenre = book['genre'];
    bool isFree = book['isFree'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Book'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
                    onSaved: (value) => title = value ?? '',
                  ),
                  TextFormField(
                    initialValue: author,
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an author'
                        : null,
                    onSaved: (value) => author = value ?? '',
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a description'
                        : null,
                    onSaved: (value) => description = value ?? '',
                    maxLines: 3,
                  ),
                  TextFormField(
                    initialValue: imageUrl,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an image URL'
                        : null,
                    onSaved: (value) => imageUrl = value ?? '',
                  ),
                  TextFormField(
                    initialValue: audioUrl,
                    decoration: const InputDecoration(labelText: 'Audio URL'),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an audio URL'
                        : null,
                    onSaved: (value) => audioUrl = value ?? '',
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGenre,
                    decoration: const InputDecoration(labelText: 'Genre'),
                    items: _bookService.categories
                        .map((genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedGenre = value!),
                  ),
                  SwitchListTile(
                    title: const Text('Is Free?'),
                    value: isFree,
                    onChanged: (value) => setDialogState(() => isFree = value),
                  ),
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
                  try {
                    await _bookService.updateBook(
                      id: book['id'],
                      genre: selectedGenre,
                      title: title,
                      author: author,
                      description: description,
                      imageUrl: imageUrl,
                      audioUrl: audioUrl,
                      isFree: isFree,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Book updated successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating book: $e')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Manager'),
      ),
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
                    '${book['author']} - ${book['genre']}${book['isFree'] ? ' (Free)' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
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
