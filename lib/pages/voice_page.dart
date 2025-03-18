import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous page
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth:100,
        title: const Text(
          "Change Voice Actor", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VoiceOption(
              name: "Female",
              imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
            ),
            SizedBox(height: 15),
            VoiceOption(
              name: "Male Voice",
              imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png", // Replace with actual female image
            ),
          ],
        ),
      ),
    );  



  }
}

class VoiceOption extends StatelessWidget {
  final String name;
  final String imageUrl;

  VoiceOption({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 25,
          ),
          Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          IconButton(
            icon: Icon(Ionicons.play_circle, color: Colors.blueAccent, size: 35),
            onPressed: () {
              print("Playing $name's voice...");
            },
          ),
        ],
      ),
    );
  }
}