import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutterquizapp/quiz_widgets.dart';

import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final quiz = await QuizLoader.loadFromBundle(
    'assets/questions.json',
  );
  log(quiz.toString());
  runApp(MainApp(quiz: quiz));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      home: QuizPage(quiz: quiz),
    );
  }
}
