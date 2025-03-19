import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String bookImagePath;
  final double rating;

  BookCard({
    required this.bookName,
    required this.authorName,
    required this.bookImagePath,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(height: 30, child: Image.asset(bookImagePath)),

              Text("Madol Doowa"),
            ],
          ),

          Text(authorName),
          Text(rating.toString()),
        ],
      ),
    );
  }
}
