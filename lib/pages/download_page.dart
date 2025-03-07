import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
          Text(
            "Download & Storage",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500
            ),
          ),

          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 180, 209, 249),
                  ),
                  child: Icon(Ionicons.download_outline, size: 26,
                  color: const Color.fromARGB(255, 29, 14, 172),),
                
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Download Quality", 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 227, 227, 227),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Ionicons.chevron_forward_outline),
                )
                ],
            ),
          ),

          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 180, 209, 249),
                  ),
                  child: Icon(Ionicons.book_outline, size: 26,
                  color: const Color.fromARGB(255, 29, 14, 172),),
                
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Offline Audio Book", 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 227, 227, 227),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Ionicons.chevron_forward_outline),
                )
                ],
            ),
          ),

      ]
      
    );
  }
}
