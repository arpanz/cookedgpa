import 'package:flutter/material.dart';
import 'gpa_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Playpen Sans",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
        iconTheme: IconThemeData(color: Colors.blue.shade800),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontFamily: "Playpen Sans",
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: "Playpen Sans"),
          titleLarge: TextStyle(fontSize: 32),
          titleMedium: TextStyle(fontSize: 22),
          titleSmall: TextStyle(fontSize: 12),
        ),
      ),
      home: GpaScreen(),
    );
  }
}
