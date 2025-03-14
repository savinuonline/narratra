import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SpeedPage extends StatefulWidget {
  final double initialSpeed;
  const SpeedPage({super.key, required this.initialSpeed});

  @override
  State<SpeedPage> createState() => _SpeedPageState();
}

class _SpeedPageState extends State<SpeedPage> {
  late double selectedSpeed;
  final List<double> speedOptions =[0.25, 0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  void initState() {
    super.initState();
    selectedSpeed = widget.initialSpeed; // Start with passed speed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, selectedSpeed); // Go back to previous page
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth:100,
        title: const Text(
          "Playback Speed", style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Select Playback Speed",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            Column(
              children: speedOptions.map((speed) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSpeed = speed;
                    });
                    Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.pop(context, selectedSpeed);
                    }); 
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: selectedSpeed == speed
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedSpeed == speed ? const Color.fromRGBO(33, 150, 243, 1) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        speed == 1.0 ? "Normal" : "${speed}x",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: selectedSpeed == speed ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),      
    );
  }
}