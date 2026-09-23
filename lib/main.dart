import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models.dart';
import 'quiz_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final quiz = await QuizLoader.loadFromBundle('assets/questions.json');
  runApp(MainApp(quiz: quiz));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: QuizPage(
        quiz: widget.quiz,
        mode: mode,
        onThemeChanged: (value) => setState(() => mode = value),
      ),
    );
  }
}
