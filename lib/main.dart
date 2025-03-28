import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:nowplaying/nowplaying.dart';
import 'package:vest1/SplashScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  // await NowPlaying.instance.start(
  //   resolveImages: true,
  //   spotifyClientId: dotenv.env['SPOTIFY_CLIENT_ID'],
  //   spotifyClientSecret: dotenv.env['SPOTIFY_CLIENT_SECRET'],
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define your custom colors
  static final Color primaryColor = Color(0xfff4ac4e);
  static final Color secondaryColor = Color(0xFFF88444);
  static final Color surfaceColor = Color(0xFFFFE4CB);
  static final Color accentColor = Color(0xFF271E18);

  // Create a custom ColorScheme
  static final ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: accentColor,
    secondary: secondaryColor,
    onSecondary: accentColor,
    error: Colors.red,
    onError: Colors.white,
    surface: surfaceColor,
    onSurface: accentColor,
  );

  // Build the MaterialApp with the custom ThemeData
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PulsePath',
      theme: ThemeData(
        colorScheme: scheme,
        // Optionally, set other theme properties
        // that use the color scheme
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
        scaffoldBackgroundColor: scheme.surface,
        textTheme: TextTheme(

          bodyMedium: TextStyle(color: accentColor),
          bodySmall: TextStyle(color: accentColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            borderSide: BorderSide(
              color: accentColor, // Default border color
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide(
              color: secondaryColor, // Border color when selected
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide(
              color: accentColor, // Border color when not selected
              width: 1.5,
            ),
          ),
          labelStyle: TextStyle(color: accentColor), // Label text color
          floatingLabelStyle: TextStyle(color: secondaryColor), // Label color when focused
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
    backgroundColor: secondaryColor, // Use secondary color
    foregroundColor: scheme.onSecondary, // Ensure text is readable
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
    ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: secondaryColor
          )
        ),
        cardTheme: CardTheme(
          color: primaryColor,
          elevation: 2,

        ),
        iconTheme: IconThemeData(
          fill: 1,
          color: accentColor,
        ),
      ),
      home: SplashScreen(),
    );
  }
}