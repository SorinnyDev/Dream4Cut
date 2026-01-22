import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';

void main() {
  runApp(const Dream4CutApp());
}

class Dream4CutApp extends StatelessWidget {
  const Dream4CutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream4Cut',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
