// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your_api_key',
    authDomain: 'your_project.firebaseapp.com',
    projectId: 'your_project',
    storageBucket: 'your_project.appspot.com',
    messagingSenderId: 'your_messaging_sender_id',
    appId: 'your_web_app_id',
    measurementId: 'your_measurement_id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your_api_key',
    appId: 'your_android_app_id',
    messagingSenderId: 'your_messaging_sender_id',
    projectId: 'your_project',
    storageBucket: 'your_project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your_api_key',
    appId: 'your_ios_app_id',
    messagingSenderId: 'your_messaging_sender_id',
    projectId: 'your_project',
    storageBucket: 'your_project.appspot.com',
    iosClientId: 'your_ios_client_id',
    iosBundleId: 'your.ios.bundle.id',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your_api_key',
    appId: 'your_macos_app_id',
    messagingSenderId: 'your_messaging_sender_id',
    projectId: 'your_project',
    storageBucket: 'your_project.appspot.com',
    iosClientId: 'your_macos_client_id',
    iosBundleId: 'your.macos.bundle.id',
  );
}
