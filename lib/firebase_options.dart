import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your actual Firebase project configuration
    return const FirebaseOptions(
      apiKey: 'AIzaSyCS5fQ5UzXAwY0rWe5bm0l9LGvVKkvdU3Q',
      appId: '1:872325044778:android:866933226e9aa84368c153',
      messagingSenderId: '872325044778',
      projectId: 'narratradb',
    );
  }
}
