import 'dart:convert';
import 'package:flutter/services.dart';

class Question {
  const Question({
    required this.question,
    required this.answers,
    required this.correct,
  });
  final String question;
  final List<String> answers;
  final List<int> correct;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      answers: List<String>.from(json['answers']),
      correct: List<int>.from(json['correct']).map((e) => e - 1).toList(),
    );
  }

  @override
  String toString() {
    return '''
  question
     |> $question
  answers
${answers.map((a) => '     |> $a').join('\n')}
  correct
     |> $correct''';
  }
}

class Quiz {
  final List<Question> questions;
  const Quiz({required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json, {int? limit}) {
    final questionsJson = json['questions'] as List<dynamic>;
    return Quiz(
      questions:
      questionsJson
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .take(limit ?? questionsJson.length)
          .toList(),
    );
  }

  @override
  String toString() {
    final separator = '-' * 80;
    return '''
$separator
${questions.join('\n$separator\n')}
$separator
    ''';
  }
}

class QuizLoader {
  static Future<Quiz> loadFromBundle(String path, {int? limit}) async {
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString);
    return Quiz.fromJson(json, limit: limit);
  }
}
