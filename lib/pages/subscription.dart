import 'package:flutter/material.dart';

class subscription extends StatelessWidget {
  const subscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Image.asset('lib/images/LogoBlue.png', height: 100),
            const SizedBox(height: 20),
            const Text(
              "Become a Premium",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.black54),
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: " Unlimited access to all Audiobooks\n\n"),
                  WidgetSpan(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: " Ad-free Experience\n\n"),
                  WidgetSpan(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: " Multiple Voice Options\n\n"),
                  WidgetSpan(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: " High Quality Audio"),
                ],
              ),
            ),
            const SizedBox(height: 50),
            subscriptionOption("Premium", "Rs.699/month", true),
            const SizedBox(height: 10),
            subscriptionOption("Premium (Family)", "Rs.1299/month", false),
            const SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Continue with Free Package",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget subscriptionOption(String title, String price, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
