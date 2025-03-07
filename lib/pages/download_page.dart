import 'package:flutter/material.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
          Text(
            "Download & Storage",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500
            ),
          ),
      ]
      
    );
  }
}
