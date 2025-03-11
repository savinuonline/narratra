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
                _buildHeaderRow(),
                const Divider(),
                _buildDataRow("360p", "600MB"),
                _buildDataRow("480p", "1.2GB"),
                _buildDataRow("720p", "2.4GB"),
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

  Widget _buildDataRow(String quality, String size){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCell(quality),
          _buildCell(size),
        ],
      ) 
    );
  }  
  
  Widget _buildCell(String text, {bool isHeader = false}){
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }


}