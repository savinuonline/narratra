import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:audioplayers/audioplayers.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  String? selectedVoice; // To track selected voice

  void selectVoice(String voice) {
    setState(() {
      selectedVoice = voice; // Update selected voice
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$voice voice selected")));
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
        leadingWidth: 100,
        title: const Text(
          "Change Voice Actor",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                imageUrl: "assets/images/female2.jpg", //image
                isSelected: selectedVoice == "Female",
                audioPath: "audio/female_voice.mp3", // audio
              ),
            ),

            SizedBox(height: 20),
            GestureDetector(
              onTap: () => selectVoice("Male"),
              child: VoiceOption(
                name: "Male",
                imageUrl: "assets/images/male1.jpg", //image
                isSelected: selectedVoice == "Male",
                audioPath: "audio/male_voice.mp3", //voice
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
  final String audioPath;

  const VoiceOption({
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.audioPath,
    super.key,
  });

  @override
  _VoiceOptionState createState() => _VoiceOptionState();
}

class _VoiceOptionState extends State<VoiceOption> {
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); //add audio player
  Duration audioDuration = Duration.zero; // Store the duration of audio

  @override
  void initState() {
    super.initState();
    _loadAudioDuration(); // Get audio duration when widget initializes
  }

  Future<void> _loadAudioDuration() async {
    await _audioPlayer.setSource(AssetSource(widget.audioPath));
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        audioDuration = d;
      });
    });
  }

  void togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.stop(); // Stop audio if playing
      setState(() {
        isPlaying = false;
      });
    } else {
      await _audioPlayer.play(AssetSource(widget.audioPath)); // Play audio
      setState(() {
        isPlaying = true;
      });

      if (audioDuration > Duration.zero) {
        Future.delayed(audioDuration, () {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Cleanup audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color:
            widget.isSelected
                ? const Color.fromARGB(255, 171, 212, 247)
                : const Color.fromARGB(
                  255,
                  171,
                  169,
                  169,
                ), // Highlight selected
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Ionicons.pause_circle : Ionicons.play_circle,
              color: const Color.fromARGB(255, 42, 101, 202),
              size: 45,
            ),
            onPressed: togglePlayPause,
          ),
        ],
      ),
    );
  }
}
