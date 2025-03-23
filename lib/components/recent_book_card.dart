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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    height: 85,
                    padding: EdgeInsets.all(5),
                    color: Colors.grey,
                    child: Image.asset(bookImagePath),
                  ),
                ),

                SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(authorName, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: EdgeInsets.all(5),
                color: Colors.amber,
                child: Text(
                  rating.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
