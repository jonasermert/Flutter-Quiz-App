import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import 'app_colors.dart';
import 'confetti.dart';
import 'models.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Flutter Quiz')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: QuizQuestion(quiz: quiz),
          ),
        ),
      ),
    );
  }
}

class QuizQuestion extends StatefulWidget {
  const QuizQuestion({super.key, required this.quiz});
  final Quiz quiz;
  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  late final List<Question> shuffledQuestions = List.from(widget.quiz.questions)
    ..shuffle();

  List<List<int>> previousAnswers = [];
  List<int> currentAnswers = [];
  bool isVerifying = false;

  final confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  bool get onLastQuestion =>
      previousAnswers.length == shuffledQuestions.length - 1;

  int? correctAnswersCountMaybe() {
    if (!isVerifying) {
      return null;
    }
    final allAnswers = [...previousAnswers, currentAnswers];
    if (allAnswers.length != shuffledQuestions.length) {
      return null;
    }
    return correctAnswersCount(allAnswers);
  }

  int correctAnswersCount(List<List<int>> allAnswers) {
    assert(allAnswers.length == shuffledQuestions.length);
    int correct = 0;
    for (int i = 0; i < shuffledQuestions.length; i++) {
      if (allAnswers[i].length == shuffledQuestions[i].correct.length &&
          allAnswers[i].every(
                (answer) => shuffledQuestions[i].correct.contains(answer),
          )) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = shuffledQuestions[previousAnswers.length];
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: QuizQuestionProgress(
                  completedCount: previousAnswers.length,
                  totalCount: widget.quiz.questions.length,
                  correctCount: correctAnswersCountMaybe(),
                  question: currentQuestion.question,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: currentQuestion.answers.length,
                itemBuilder: (context, index) {
                  if (currentQuestion.correct.length == 1) {
                    return QuizRadioListTile(
                      key: Key('${previousAnswers.length}-$index'),
                      answer: currentQuestion.answers[index],
                      currentIndex: index,
                      selectedIndex:
                      currentAnswers.isEmpty ? -1 : currentAnswers[0],
                      isVerifying: isVerifying,
                      isCorrect: currentQuestion.correct.contains(index),
                      onChanged:
                      isVerifying
                          ? null
                          : (index) {
                        setState(() {
                          currentAnswers = [index];
                        });
                      },
                    );
                  } else {
                    return QuizCheckboxListTile(
                      key: Key('${previousAnswers.length}-$index'),
                      answer: currentQuestion.answers[index],
                      isVerifying: isVerifying,
                      isCorrect: currentQuestion.correct.contains(index),
                      isSelected: currentAnswers.contains(index),
                      onChanged:
                      isVerifying
                          ? null
                          : (completed) {
                        setState(() {
                          if (completed) {
                            currentAnswers.add(index);
                          } else {
                            currentAnswers.remove(index);
                          }
                        });
                      },
                    );
                  }
                },
              ),
            ),
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed:
                  currentAnswers.isEmpty
                      ? null
                      : () {
                    setState(() {
                      if (isVerifying) {
                        if (onLastQuestion) {
                          // Reset the quiz
                          previousAnswers = [];
                          confettiController.stop();
                          shuffledQuestions.shuffle();
                        } else {
                          previousAnswers.add(currentAnswers);
                        }
                        currentAnswers = [];
                      } else {
                        final updatedAnswers = [
                          ...previousAnswers,
                          currentAnswers,
                        ];
                        if (onLastQuestion &&
                            correctAnswersCount(updatedAnswers) ==
                                shuffledQuestions.length) {
                          confettiController.play();
                        }
                      }
                      isVerifying = !isVerifying;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      isVerifying
                          ? (onLastQuestion ? 'Try Again' : 'Next Question')
                          : 'Submit',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ConfettiWrapper(confettiController: confettiController),
      ],
    );
  }
}

class QuizQuestionProgress extends StatelessWidget {
  const QuizQuestionProgress({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.correctCount,
    required this.question,
  });
  final int completedCount;
  final int totalCount;
  final int? correctCount;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question ${completedCount + 1} of $totalCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (correctCount != null)
              Text(
                'You scored $correctCount out of $totalCount (${(correctCount! / totalCount * 100).round()}%)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(value: (completedCount + 1) / totalCount),
        SizedBox(height: 24),
        Text(question, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class QuizRadioListTile extends StatelessWidget {
  const QuizRadioListTile({
    super.key,
    required this.answer,
    required this.currentIndex,
    required this.selectedIndex,
    required this.onChanged,
    required this.isVerifying,
    required this.isCorrect,
  });
  final String answer;
  final int currentIndex;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final bool isVerifying;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      groupValue: selectedIndex,
      value: currentIndex,
      onChanged:
      isVerifying
          ? null
          : (int? newValue) {
        if (newValue != null) {
          onChanged?.call(newValue);
        }
      },
      title: Text(answer, style: Theme.of(context).textTheme.bodyLarge),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      tileColor: AppColors.getTileColor(
        isVerifying: isVerifying,
        isCorrect: isCorrect,
        isSelected: selectedIndex == currentIndex,
      ),
    );
  }
}

// Checkbox list tile for a multiple answer question
class QuizCheckboxListTile extends StatelessWidget {
  const QuizCheckboxListTile({
    super.key,
    required this.answer,
    required this.isSelected,
    required this.onChanged,
    required this.isVerifying,
    required this.isCorrect,
  });
  final String answer;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;
  final bool isVerifying;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      onChanged:
      isVerifying
          ? null
          : (bool? newValue) {
        if (newValue != null) {
          onChanged?.call(newValue);
        }
      },
      title: Text(answer, style: Theme.of(context).textTheme.bodyLarge),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      tileColor: AppColors.getTileColor(
        isVerifying: isVerifying,
        isCorrect: isCorrect,
        isSelected: isSelected,
      ),
    );
  }
}
