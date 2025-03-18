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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            VoiceOption(
              name: "Female",
              imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
            ),
            SizedBox(height: 20),
            VoiceOption(
              name: "Male",
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
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 171, 169, 169),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 50,
          ),
          Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          IconButton(
            icon: Icon(Ionicons.play_circle, color: const Color.fromARGB(255, 42, 101, 202), size: 45),
            onPressed: () {
              print("Playing $name's voice...");
            },
          ),
        ],
      ),
    );
  }
}