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
              imageUrl: "assets/images/female2.jpg",
            ),
            SizedBox(height: 20),
            VoiceOption(
              name: "Male",
              imageUrl: "assets/images/male1.jpg", // Replace with actual female image
            ),
          ],
        ),
      ),
    );  



  }
}

class VoiceOption extends StatefulWidget {
  final String name;
  final String imageUrl;

  const VoiceOption({required this.name, required this.imageUrl, Key? key}) : super(key: key);

  @override
   _VoiceOptionState createState() => _VoiceOptionState();
}
  
  class _VoiceOptionState extends State<VoiceOption> {
    bool isplaying = false;

    void togglePlayPause() {
      setState(() {
        isplaying = !isplaying;
      });

      Future.delayed(Duration(seconds: 5), (){
        if (mounted){
          setState(() {
            isplaying = false;
          });
        }
      });
    }

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
            backgroundImage: AssetImage(widget.imageUrl),
            radius: 50,
          ),
          Text(
            widget.name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          IconButton(
            icon: Icon(
              isplaying? Ionicons.pause_circle: Ionicons.play_circle,
              color: const Color.fromARGB(255, 42, 101, 202), size: 45),
            onPressed: togglePlayPause,
          ),
        ],
      ),
    );
  }
}