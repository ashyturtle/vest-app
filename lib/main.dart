import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vest1/SplashScreen.dart';
import 'package:vest1/musicPlayerPage.dart';
import 'package:vest1/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color primaryColor = Color(0xFFF4E04D);
  static const Color secondaryColor = Color(0xFFC5FFFD);
  static const Color accentColor = Color(0xFF99C5FF);
  static const Color backgroundColor = Color(0xFFD6D7D7);
  static const Color surfaceColor = Color(0xFF2D3142);

  static final ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: surfaceColor,
    secondary: secondaryColor,
    onSecondary: accentColor,
    error: Colors.red,
    onError: Colors.white,
    background: surfaceColor,
    onBackground: accentColor,
    surface: surfaceColor,
    onSurface: accentColor,
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
          bodyMedium: TextStyle(color: scheme.onBackground),
          bodySmall: TextStyle(color: scheme.onBackground),
        ),
        // You can define more theme properties as needed
      ),
      home: RoutePage()
    );
  }
}

