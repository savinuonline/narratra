import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
   State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  String? selectedVoice;  // To track selected voice

  void selectVoice(String voice) {
    setState(() {
      selectedVoice = voice;  // Update selected voice
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$voice voice selected")),
    );
  }

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
             GestureDetector(
              onTap: () => selectVoice("Female"), 
              child: VoiceOption(
                name: "Female",
                imageUrl: "assets/images/female2.jpg",  //image
                isSelected: selectedVoice == "Female",
              ),
            ),
            
            SizedBox(height: 20),
            GestureDetector(
              onTap: ()  => selectVoice("Male"),
              child: VoiceOption(
                name: "Male",
                imageUrl: "assets/images/male1.jpg", //image
                isSelected: selectedVoice == "Male", 
              ),
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
  final bool isSelected;

  const VoiceOption({required this.name, required this.imageUrl, required this.isSelected, super.key});


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
        color: widget.isSelected ? const Color.fromARGB(255, 171, 212, 247) : Color.fromARGB(255, 171, 169, 169), // highlight selected
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.isSelected ? Colors.blue : Colors.transparent,
          width: 3,
        ),
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