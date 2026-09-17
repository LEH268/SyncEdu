import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';

import '../widgets/emoji_app_bar.dart';
import '../widgets/emoji_scope.dart';
import 'quiz_controller.dart';

/// Shows one question at a time and advances as soon as the student picks an
/// option. There is no "next" button -- one tap is the whole interaction.
class QuizRunner extends StatelessWidget {
  const QuizRunner({
    super.key,
    required this.controller,
    this.onComplete,
    this.onNewRange,
  });

  final QuizController controller;

  /// Called once the last question has been answered.
  final VoidCallback? onComplete;

  /// Offered when assembly produced nothing to ask, so an empty range is not
  /// a dead end.
  final VoidCallback? onNewRange;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final int total = controller.questions.length;
        final PoolQuestion? question = controller.currentQuestion;

        // Assembly found nothing for this range. Completing here would record
        // a `question_count: 0` attempt, which the server rejects outright and
        // which reads to the student as "0 of 0" -- so say what happened.
        if (total == 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nothing to practise')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'There are no questions for this range yet. Try a '
                      'different chapter, or come back once this one has been '
                      'covered.',
                      textAlign: TextAlign.center,
                    ),
                    if (onNewRange != null) ...<Widget>[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        key: const Key('empty-new-range'),
                        onPressed: onNewRange,
                        child: const Text('Choose a different range'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        if (question == null) {
          // Guarded on the controller's own flag as well: this callback is
          // scheduled from every build, and a notify inside that window would
          // otherwise submit the same answers twice.
          if (onComplete != null && !controller.isSubmitted) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => onComplete!.call());
          }
          return const Scaffold(body: SizedBox.shrink());
        }

        final int position = controller.currentIndex + 1;

        return Scaffold(
          appBar: EmojiAppBar(title: '$position of $total'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    question.stem,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  for (int i = 0; i < question.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            EmojiScope.maybeOf(context)?.setState(
                              i == question.correctIndex
                                  ? EmojiState.happy
                                  : EmojiState.confused,
                            );
                            controller.answer(i);
                          },
                          child: Text(question.options[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
