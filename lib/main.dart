import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/goal_provider.dart';
import 'views/main_scaffold.dart';

import 'services/notification_service.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const Dream4CutApp(),
    ),
  );
}

class Dream4CutApp extends StatelessWidget {
  const Dream4CutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream4Cut',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(),
    );
  }
}
