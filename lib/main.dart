import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/helpers/theme.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(),
        ),
      ],
      builder: (context, Index){
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          title: 'darkMode',
          theme: MyTheme.lightTheme,
          darkTheme: MyTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SettingsPage(),
        );
      },
    );
  
  }
}
