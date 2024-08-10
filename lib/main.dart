import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vest1/SplashScreen.dart';
import 'package:vest1/firebase_options.dart';
import 'package:vest1/musicPlayerPage.dart';
import 'package:vest1/route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color primaryColor = Color(0xFFF4E04D);
  static const Color secondaryColor = Color(0xFFC5FFFD);
  static const Color accentColor = Color(0xFFD89A9E);
  static const Color backgroundColor = Color(0xFF5F5449);
  static const Color surfaceColor = Color(0xFF8DB1AB);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(
          ),
        colorScheme: const ColorScheme(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
          background: backgroundColor,
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
          brightness: Brightness.light
        )

      ),
      home: RoutePage()
    );
  }
}

