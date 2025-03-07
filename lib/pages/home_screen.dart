import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/book.dart';
import 'player_screen.dart'; // Import the player screen

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The 4 categories
  final List<String> categories = [
    "Trending",
    "Recommends",
    "Today For You",
    "Free Books",
  ];

  // Placeholder books used for each category, now using asset images
  final List<Book> placeholderBooks = List.generate(
    6,
        (index) => Book(
      id: 'book_$index',
      title: 'Placeholder Book $index',
      author: 'Author $index',
      genre: 'Fiction',
      imageUrl: 'assets/images/books.png', // local asset image path
      description: 'This is a description for placeholder book $index. It gives a brief overview of the story and the content.',
    ),
  );

  // Bottom navigation index
  int _selectedIndex = 0;

  // Handle bottom nav taps
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, navigate or switch pages based on index.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom navigation bar with 5 items: Explore, Search, Library, Play, Profile.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // The entire page scrolls vertically
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              // Build each category with a horizontal list of books
              ...categories.map((cat) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(cat),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180, // Fixed height for horizontal cards
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: placeholderBooks.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final book = placeholderBooks[index];
                          return GestureDetector(
                            onTap: () => _showBookDetails(book),
                            child: _buildHorizontalBookCard(book),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Pops up a modal bottom sheet with book details and a play button.
  void _showBookDetails(Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      book.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text("Author: ${book.author}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text("Genre: ${book.genre}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(book.description,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlayerScreen(book: book)),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Greeting section at the top
  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${widget.user.displayName}!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Good Evening",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // Avatar from local asset
        const CircleAvatar(
          radius: 26,
          backgroundImage: AssetImage('assets/images/avatar.png'),
        ),
      ],
    );
  }

  /// Search bar placeholder
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search audiobooks...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Category title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Horizontal book card widget using asset images
  Widget _buildHorizontalBookCard(Book book) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover loaded from asset or network
            book.imageUrl.startsWith('assets/')
                ? Image.asset(
              book.imageUrl,
              height: 90,
              width: 140,
              fit: BoxFit.cover,
            )
                : Image.network(
              book.imageUrl,
              height: 90,
              width: 140,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Author: ${book.author}",
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
