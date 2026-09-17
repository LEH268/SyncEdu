import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'onboarding_repository.dart';

/// The five reflection statements. Fixed and small: this supplies the 30%
/// student component of the Class Fit Analyzer, and the mean of the answers
/// is the `studentPct` the analyzer reads.
const List<String> kReflectionStatements = <String>[
  'I feel I belong in my current class.',
  'The pace of lessons suits how I learn.',
  'I can get help from my teacher when I am stuck.',
  'I am making the progress I hoped for this year.',
  'I would choose to stay in this class next year.',
];

/// Raised on next launch when an administrator has opened a campaign the
/// student has not answered (spec §7.4). Works fully offline.
class YearEndReflectionScreen extends StatefulWidget {
  const YearEndReflectionScreen({
    super.key,
    required this.repository,
    required this.studentId,
    required this.schoolId,
    required this.campaign,
    required this.onComplete,
  });

  final OnboardingRepository repository;
  final String studentId;
  final String schoolId;
  final ReflectionCampaign campaign;
  final VoidCallback onComplete;

  @override
  State<YearEndReflectionScreen> createState() => _YearEndReflectionScreenState();
}

class _YearEndReflectionScreenState extends State<YearEndReflectionScreen> {
  final Map<int, int> _answers = <int, int>{};
  final TextEditingController _note = TextEditingController();
  bool _submitting = false;

  bool get _complete => _answers.length == kReflectionStatements.length;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.repository.submitReflection(
      studentId: widget.studentId,
      schoolId: widget.schoolId,
      campaign: widget.campaign,
      likertAnswers: <String, int>{
        for (final MapEntry<int, int> e in _answers.entries)
          'q${e.key}': e.value,
      },
      freeText: _note.text,
    );
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Year-End Reflection — ${widget.campaign.academicYear}'),
        automaticallyImplyLeading: false,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                const Text(
                  'Your answers help your school check that your class is a '
                  'good fit. Only staff see the result.',
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < kReflectionStatements.length; i++) ...<Widget>[
                  Text(kReflectionStatements[i],
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      for (int score = 1; score <= 5; score++)
                        ChoiceChip(
                          key: Key('reflection-$i-$score'),
                          label: Text('$score'),
                          selected: _answers[i] == score,
                          onSelected: (_) => setState(() => _answers[i] = score),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  key: const Key('reflection-note'),
                  controller: _note,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Anything else you want your teacher to know?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('reflection-submit'),
                  onPressed: _complete ? _submit : null,
                  child: Text(_complete
                      ? 'Submit'
                      : 'Answer all ${kReflectionStatements.length} statements'),
                ),
              ],
            ),
    );
  }
}
