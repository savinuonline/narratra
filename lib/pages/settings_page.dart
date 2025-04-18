import 'package:flutter/material.dart';
import 'package:frontend/helpers/theme.dart';
import 'package:frontend/pages/voice_page.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:frontend/pages/download_page.dart';
import 'package:frontend/pages/actions_page.dart';
import 'package:frontend/pages/speed_page.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double selectedSpeed = 1.0;

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
          "Settings",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Play & Audio Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final newSpeed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SpeedPage(initialSpeed: selectedSpeed),
                    ),
                  );
                  if (newSpeed != null && newSpeed is double) {
                    setState(() {
                      selectedSpeed = newSpeed;
                    });
                  }
                },

                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 218, 245, 204),
                      ),
                      child: Icon(
                        Ionicons.play_circle_outline,
                        size: 26,
                        color: const Color.fromARGB(255, 3, 116, 16),
                      ),
                    ),

                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Play Speed",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      selectedSpeed == 1.0 ? "Normal" : "${selectedSpeed}x",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(width: 10),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 227, 227, 227),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Ionicons.chevron_forward_outline,
                        color: Theme.of(context).chevronColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 218, 245, 204),
                    ),
                    child: Icon(
                      Ionicons.mic_outline,
                      size: 26,
                      color: const Color.fromARGB(255, 3, 94, 14),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Change Voice Actor",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoicePage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 227, 227, 227),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Ionicons.chevron_forward_outline,
                        color: Theme.of(context).chevronColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            DownloadPage(),
            ChangeNotifierProvider(
              create: (_) => ThemeProvider(),
              child: ActionsPage(),
            ),
          ],
        ),
      ),
    );
  }
}
