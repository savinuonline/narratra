import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding: const EdgeInsets.all(20.0),
          child: row(
            MainAxisAlignment: MainAxisAlignment.center,
            children: [
              stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/profile.jpg"),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      Radius: 0,
                      backgroundColor: colors.blueAccent,
                      child: Icon(Icon.edit, Color: colors.white, size: 16)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ), 
    ),
        
  }
}
