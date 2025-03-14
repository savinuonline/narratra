import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({Key? key}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  String _title = '';
  String _author = '';
  String _selectedGenre = "Children's literature"; // default value
  String _description = '';
  String _imageUrl = '';
  String _audioUrl = '';
  bool _isFree = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final bookId = await _firebaseService.addBook(
          title: _title,
          author: _author,
          genre: _selectedGenre,
          description: _description,
          imageUrl: _imageUrl,
          audioUrl: _audioUrl,
          isFree: _isFree,
          likeCount: 0,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book added successfully! ID: $bookId')),
        );

        // Clear the form
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
        backgroundColor: const Color(0xFF402e7a),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _author = value ?? '',
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: _firebaseService.categories.map((genre) {
                  return DropdownMenuItem(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value ?? "Children's literature";
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'lib/images/your-image.jpg',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _imageUrl = value ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Audio URL',
                  hintText: 'https://example.com/audio.mp3',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _audioUrl = value ?? '',
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Is Free?'),
                value: _isFree,
                onChanged: (bool value) {
                  setState(() {
                    _isFree = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF402e7a),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Book',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 