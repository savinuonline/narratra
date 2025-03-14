import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class QualityPage extends StatelessWidget {
  const QualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous page
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth:100,
        title: const Text(
          "Download Quality", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Column(
              children: [
                const SizedBox(height:10),
                _buildHeaderRow(),
                const Divider(),
                _buildDataRow("360p", context, "600MB"),
                _buildDataRow("480p", context,  "1.2GB"),
                _buildDataRow("720p", context, "2.4GB"),
                 // Separates header from data rows
                
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCell("Audio Quality", isHeader: true),
          _buildCell("File Size", isHeader: true),
        ],
      ),
    );
  }

  Widget _buildDataRow(String quality, BuildContext context, String size){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Downloading $quality quality...")),
              );    
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 69, 163, 239), // Red button
              foregroundColor: Colors.white, // White text
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quality,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8), // Space between text and icon
                const Icon(Ionicons.download_outline, size: 22, color: Colors.white),
              ],
            ),
          ),
          // File Size Text
          Text(
            size,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ) 
    );
  }  
  
  Widget _buildCell(String text, {bool isHeader = false}){
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }


}