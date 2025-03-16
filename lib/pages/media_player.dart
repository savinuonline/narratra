import 'package:flutter/material.dart';

class MediaPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100, // Background gradient color
      appBar: AppBar(
        title: Text("Now Playing"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(
                    "assets/audiobook_cover.jpg",
                  ), // Replace with your audiobook cover
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Title and Author
          Text(
            "Something in the Way",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Nirvana",
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),

          SizedBox(height: 20),

          // Progress Bar
          Slider(
            value: 0,
            min: 0,
            max: 100,
            onChanged: (value) {},
            activeColor: Colors.blue,
          ),

          // Duration Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("0:00"), Text("4:13")],
            ),
          ),

          SizedBox(height: 20),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.repeat, size: 30), onPressed: () {}),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.skip_previous, size: 35),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  size: 60,
                  color: Colors.blue,
                ),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.skip_next, size: 35),
                onPressed: () {},
              ),
              SizedBox(width: 20),
              IconButton(icon: Icon(Icons.shuffle, size: 30), onPressed: () {}),
            ],
          ),

          SizedBox(height: 30),

          // Waveform Design (Decoration)
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Colors.blue.shade200,
            ),
            child: Center(
              child: Text(
                "Waveform Visualization Here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
