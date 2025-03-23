import 'package:flutter/material.dart';

class RecentBookCard extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String bookImagePath;
  final double rating;
  final String duration;

  RecentBookCard({
    required this.bookName,
    required this.authorName,
    required this.bookImagePath,
    required this.rating,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(height: 40, child: Image.asset(bookImagePath)),

          Column(children: [Text(bookName), Text(authorName)]),
          Text(rating.toString()),
        ],
      ),
    );
  }
}
