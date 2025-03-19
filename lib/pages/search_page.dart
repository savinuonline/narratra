import 'package:flutter/material.dart';
import 'package:frontend/components/book_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          //App Bar
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
                height: 100,
                color: Colors.grey[800],
              ),
            ),
          ),

          SizedBox(height: 24),

          //Discover a New Story
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Discover a New Stroy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),

          SizedBox(height: 25),

          //Search Bar
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
                        Expanded(
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

                SizedBox(width: 10),

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

          SizedBox(height: 50),

          //for you book cards
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "For You",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),

          SizedBox(height: 25),

          Container(
            height: 200,
            child: ListView.builder(
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return BookCard(
                  bookName: "Madol Doowa",
                  authorName: "Martin Wickramasinghe",
                  bookImagePath: 'lib/images/madoldoowa.jpg',
                  rating: 4.5,
                );
              },
            ),
          ),

          //recently added
        ],
      ),
    );
  }
}
