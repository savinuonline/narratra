import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookCard extends StatelessWidget {
  final String bookName;
  final String authorName;
  final String bookImagePath;
  final double rating;
  final String duration;

  const BookCard({
    super.key,
    required this.bookName,
    required this.authorName,
    required this.bookImagePath,
    required this.rating,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(12),
          color: Colors.lightGreen[100],
          child: Row(
            children: [
              // Book Image
              Container(
                width: 148,
                height: 250,
                child: Image.asset(bookImagePath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),

              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(bookName, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Author :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(authorName, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Duration :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(duration, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Ratings :',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(rating.toString(), style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder:
                              (context, index) =>
                                  Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18.0,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
