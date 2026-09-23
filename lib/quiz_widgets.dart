import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'confetti.dart';
import 'models.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.quiz,
    required this.mode,
    required this.onThemeChanged,
  });

  final Quiz quiz;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> questions;
  final previousAnswers = <List<int>>[];
  final selectedAnswers = <int>{};
  final confettiController = ConfettiController(duration: const Duration(seconds: 3));
  bool revealed = false;

  @override
  void initState() {
    super.initState();
    questions = List.of(widget.quiz.questions)..shuffle();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  int get index => previousAnswers.length;
  bool get isLast => index == questions.length - 1;
  Question get question => questions[index];

  bool isCorrect(Question item, Iterable<int> selection) {
    return selection.toSet().length == item.correct.length &&
        selection.toSet().containsAll(item.correct);
  }

  int get score {
    var count = 0;
    for (var i = 0; i < previousAnswers.length; i++) {
      if (isCorrect(questions[i], previousAnswers[i])) count++;
    }
    if (revealed && isCorrect(question, selectedAnswers)) count++;
    return count;
  }

  void advance() {
    if (!revealed && selectedAnswers.isEmpty) return;
    setState(() {
      if (!revealed) {
        revealed = true;
        if (isLast && score == questions.length) confettiController.play();
      } else if (isLast) {
        previousAnswers.clear();
        selectedAnswers.clear();
        questions = List.of(widget.quiz.questions)..shuffle();
        revealed = false;
        confettiController.stop();
      } else {
        previousAnswers.add(selectedAnswers.toList());
        selectedAnswers.clear();
        revealed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Keine Fragen verfügbar.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz'),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Darstellung wählen',
            icon: const Icon(Icons.brightness_6_rounded),
            initialValue: widget.mode,
            onSelected: widget.onThemeChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ThemeMode.system, child: Text('Systemeinstellung')),
              PopupMenuItem(value: ThemeMode.light, child: Text('Hell')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dunkel')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(Icons.quiz_rounded, color: colors.onPrimaryContainer),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text('Teste dein Wissen', style: theme.textTheme.headlineMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text('Frage ${index + 1} von ${questions.length}',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(value: (index + 1) / questions.length),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(question.question, style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(
                                    question.correct.length == 1
                                        ? 'Wähle eine Antwort.'
                                        : 'Wähle alle richtigen Antworten.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          for (var answerIndex = 0;
                              answerIndex < question.answers.length;
                              answerIndex++) ...[
                            _AnswerCard(
                              key: ValueKey('$index-$answerIndex'),
                              label: question.answers[answerIndex],
                              selected: selectedAnswers.contains(answerIndex),
                              correct: question.correct.contains(answerIndex),
                              revealed: revealed,
                              multiple: question.correct.length > 1,
                              onTap: revealed
                                  ? null
                                  : () => setState(() {
                                        if (question.correct.length == 1) {
                                          selectedAnswers
                                            ..clear()
                                            ..add(answerIndex);
                                        } else if (!selectedAnswers.add(answerIndex)) {
                                          selectedAnswers.remove(answerIndex);
                                        }
                                      }),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (revealed)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                isLast
                                    ? 'Ergebnis: $score von ${questions.length} richtig'
                                    : isCorrect(question, selectedAnswers)
                                        ? 'Richtig beantwortet!'
                                        : 'Die markierten Antworten sind richtig.',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: revealed || selectedAnswers.isNotEmpty ? advance : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              revealed
                                  ? isLast ? 'Erneut spielen' : 'Nächste Frage'
                                  : 'Antwort prüfen',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ConfettiWrapper(confettiController: confettiController),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    super.key,
    required this.label,
    required this.selected,
    required this.correct,
    required this.revealed,
    required this.multiple,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool revealed;
  final bool multiple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlighted = revealed ? correct : selected;
    final background = revealed && correct
        ? colors.tertiaryContainer
        : revealed && selected
            ? colors.errorContainer
            : highlighted
                ? colors.primaryContainer
                : colors.surface;
    final foreground = revealed && correct
        ? colors.onTertiaryContainer
        : revealed && selected
            ? colors.onErrorContainer
            : highlighted
                ? colors.onPrimaryContainer
                : colors.onSurface;
    return Card(
      color: background,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Icon(
                revealed && correct
                    ? Icons.check_circle_rounded
                    : revealed && selected
                        ? Icons.cancel_rounded
                        : multiple
                            ? selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded
                            : selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: foreground,
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: TextStyle(color: foreground, fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
