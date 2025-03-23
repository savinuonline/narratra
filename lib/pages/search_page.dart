import 'package:flutter/material.dart';
import 'package:frontend/components/book_card.dart';
import 'package:frontend/components/recent_book_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List booksForYou = [
    //[bookname, authorname, bookImagePath, rating, duration]
    [
      "Madol Doowa",
      "Martin Wickramasinghe",
      'lib/images/madoldoowa.jpg',
      4.5,
      "2h 45min",
    ],

    [
      "Sherlock Holmes",
      "Sir Arthur Conan Doyle",
      'lib/images/sherlockHolmes.jpeg',
      4.9,
      "3h 40min",
    ],

    [
      "robinson crusoe",
      "Daniel Defoe",
      'lib/images/robinson.jpg',
      4.2,
      "2h 50min",
    ],
  ];

  final List recentBooks = [
    //[bookname, authorname, bookImagePath, rating, duration]
    [
      "Madol Doowa",
      "Martin Wickramasinghe",
      'lib/images/madoldoowa.jpg',
      4.5,
      "2h 45min",
    ],

    [
      "Sherlock Holmes",
      "Sir Arthur Conan Doyle",
      'lib/images/sherlockHolmes.jpeg',
      4.9,
      "3h 40min",
    ],

    [
      "robinson crusoe",
      "Daniel Defoe",
      'lib/images/robinson.jpg',
      4.2,
      "2h 50min",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          // App Bar
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: Image.asset(
                'lib/images/menu.png',
                height: 30,
                color: Colors.grey[800],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Discover a New Story
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Discover a New Story",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),

          const SizedBox(height: 25),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            height: 30,
                            child: Image.asset(
                              'lib/images/search.png',
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search for a book",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 129, 27, 213),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'lib/images/preferences.png',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // For You
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "For You",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),

          const SizedBox(height: 25),

          // Book Cards List
          Container(
            height: 250,
            child: ListView.builder(
              itemCount: booksForYou.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return BookCard(
                  bookName: booksForYou[index][0],
                  authorName: booksForYou[index][1],
                  bookImagePath: booksForYou[index][2],
                  rating: booksForYou[index][3],
                  duration: booksForYou[index][4],
                );
              },
            ),
          ),

          SizedBox(height: 25),
          //recently added
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Recently Added",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              itemCount: recentBooks.length,
              itemBuilder: (context, index) {
                return RecentBookCard(
                  bookName: booksForYou[index][0],
                  authorName: booksForYou[index][1],
                  bookImagePath: booksForYou[index][2],
                  rating: booksForYou[index][3],
                  duration: booksForYou[index][4],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
