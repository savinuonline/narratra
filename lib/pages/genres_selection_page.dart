import 'package:flutter/material.dart';

/// Simple data class for each genre
class GenreData {
  final String name;
  final IconData icon;
  final MaterialColor color;

  GenreData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class GenresSelectionPage extends StatefulWidget {
  @override
  _GenresSelectionPageState createState() => _GenresSelectionPageState();
}

class _GenresSelectionPageState extends State<GenresSelectionPage> {
  /// Only the 6 requested genres
  final List<GenreData> allGenres = [
    GenreData(name: 'Literary Fiction', icon: Icons.menu_book, color: Colors.pink),
    GenreData(name: 'Thriller', icon: Icons.local_police, color: Colors.deepPurple),
    GenreData(name: 'Fantasy', icon: Icons.auto_awesome, color: Colors.blue),
    GenreData(name: 'Horror', icon: Icons.warning, color: Colors.deepOrange),
    GenreData(name: 'Romance', icon: Icons.favorite, color: Colors.red),
    GenreData(name: 'Adventure', icon: Icons.flight_takeoff, color: Colors.green),
  ];

  /// Keep track of which genres are selected
  final Set<String> selectedGenres = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a more playful title
      appBar: AppBar(
        title: const Text('Discover Your Next Read'),
        elevation: 0, // for a cleaner look with the gradient
      ),
      body: Container(
        // Gradient background for a modern look
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // A headline to draw user’s attention
            const Text(
              "What Are You Into?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // A subtitle for instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Pick the categories you love, so we can tailor your reading recommendations just for you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Genre chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allGenres.map((genre) {
                        final bool isSelected = selectedGenres.contains(genre.name);
                        return GenreButton(
                          genre: genre,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedGenres.remove(genre.name);
                              } else {
                                selectedGenres.add(genre.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Optional illustration to fill space (replace URL or use local asset)
                    Image.network(
                      "https://raw.githubusercontent.com/devefy/Flutter-Illustrations/master/illustrations/reading_side.png",
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),

            // Continue button at the bottom center
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton(
                onPressed: () {
                  // Here you can save selectedGenres to Firebase or pass them to the home page
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom widget for a single genre chip/button.
class GenreButton extends StatelessWidget {
  final GenreData genre;
  final bool selected;
  final VoidCallback onTap;

  const GenreButton({
    Key? key,
    required this.genre,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = genre.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.shade700 : color.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              genre.icon,
              color: selected ? Colors.white : color.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              genre.name,
              style: TextStyle(
                color: selected ? Colors.white : color.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
