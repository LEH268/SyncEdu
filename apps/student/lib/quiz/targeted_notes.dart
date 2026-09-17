import 'package:flutter/material.dart';

import 'quiz_controller.dart';

/// Shows the explanations for whatever the student missed, in place of a
/// fifth quiz. Rendered as simple Markdown-ish text: a heading line naming
/// the micro-skill, then its explanation body.
class TargetedNotes extends StatelessWidget {
  const TargetedNotes({super.key, required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        final Set<String> skills = controller.missedMicroSkills;
        final Map<String, List<String>> notes = controller.notes;

        return Scaffold(
          appBar: AppBar(title: const Text('Notes')),
          body: skills.isEmpty
              ? const Center(child: Text('No notes for a perfect score.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    // Looked up by micro-skill id, never by position: a skill
                    // may have no explanation on file or several, so zipping
                    // the two would file one skill's body under another's
                    // heading.
                    for (final String skillId in skills)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '## ${controller.labelFor(skillId)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (notes[skillId]?.isNotEmpty ?? false)
                              for (final String body in notes[skillId]!)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(body),
                                )
                            else
                              Text(
                                'No notes on file for '
                                '${controller.labelFor(skillId)} yet.',
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
