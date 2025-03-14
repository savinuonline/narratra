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
    return MaterialApp(
      title: 'Book Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
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
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an author' : null,
                    onSaved: (value) => author = value ?? '',
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a description' : null,
                    onSaved: (value) => description = value ?? '',
                    maxLines: 3,
                  ),
                  TextFormField(
                    initialValue: imageUrl,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an image URL' : null,
                    onSaved: (value) => imageUrl = value ?? '',
                  ),
                  TextFormField(
                    initialValue: audioUrl,
                    decoration: const InputDecoration(labelText: 'Audio URL'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an audio URL' : null,
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
                        const SnackBar(content: Text('Book updated successfully')),
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
              return ListTile(
                title: Text(book['title']),
                subtitle: Text(
                    '${book['author']} - ${book['genre']}${book['isFree'] ? ' (Free)' : ''}'),
                leading: CircleAvatar(child: Text(book['id'])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditBookDialog(book),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteBook(book['id'], book['genre']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
