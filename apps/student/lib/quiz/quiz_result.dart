import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import '../widgets/emoji_app_bar.dart';
import 'quiz_controller.dart';

/// The end-of-attempt screen. Shows the score, what each question tested (not
/// merely whether it was right), and offers the four adaptive follow-ups.
class QuizResult extends StatelessWidget {
  const QuizResult({
    super.key,
    required this.controller,
    this.onRegenerate,
    this.onPractiseMistakes,
    this.onNewRange,
    this.onNotes,
  });

  final QuizController controller;

  /// Each follow-up both reassembles (or loads notes) *and* navigates, so the
  /// controller call and the route change belong together in one callback --
  /// splitting them left the student staring at a silently reassembled quiz
  /// on the results screen.
  final VoidCallback? onRegenerate;
  final VoidCallback? onPractiseMistakes;
  final VoidCallback? onNewRange;
  final VoidCallback? onNotes;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final List<PoolQuestion> questions = controller.questions;
        final List<int?> answers = controller.answers;
        final int total = questions.length;
        final int score = controller.score;
        final bool perfect = controller.isPerfect;

        return Scaffold(
          appBar: const EmojiAppBar(title: 'Results'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                'Score: $score of $total',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (controller.relaxedSeenSet)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Some of these questions may have been seen before -- '
                    'there were not enough new ones to fill the quiz.',
                  ),
                ),
              const SizedBox(height: 16),
              const Text('What each question tested:'),
              const SizedBox(height: 8),
              for (int i = 0; i < questions.length; i++)
                ListTile(
                  leading: Icon(
                    (i < answers.length &&
                            answers[i] == questions[i].correctIndex)
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: (i < answers.length &&
                            answers[i] == questions[i].correctIndex)
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(controller.labelFor(questions[i].microSkillId)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('option-regenerate'),
                  onPressed: onRegenerate,
                  child: const Text('Try more like this'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('option-practise-mistakes'),
                  onPressed: onPractiseMistakes,
                  child: Text(
                    perfect ? 'Harder questions' : 'Practise what I got wrong',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('option-new-range'),
                  onPressed: onNewRange,
                  child: const Text('Choose a different range'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('option-notes'),
                  onPressed: onNotes,
                  child: const Text('See notes on what I missed'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
