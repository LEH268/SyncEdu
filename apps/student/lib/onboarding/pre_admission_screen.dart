import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import 'onboarding_repository.dart';

/// The mandatory Pre-admission Test. Twenty questions, one on screen at a
/// time, scored on-device — no network, no model call. On completion the
/// result is written locally and the router gate lifts.
class PreAdmissionScreen extends StatefulWidget {
  const PreAdmissionScreen({
    super.key,
    required this.repository,
    required this.studentId,
    required this.schoolId,
    required this.onComplete,
  });

  final OnboardingRepository repository;
  final String studentId;
  final String schoolId;
  final void Function(PreAdmissionProfile profile) onComplete;

  @override
  State<PreAdmissionScreen> createState() => _PreAdmissionScreenState();
}

class _PreAdmissionScreenState extends State<PreAdmissionScreen> {
  final List<int> _answers = <int>[];
  bool _submitting = false;

  int get _index => _answers.length;
  PreAdmissionQuestion get _question => kPreAdmissionInstrument[_index];

  Future<void> _choose(int optionIndex) async {
    setState(() => _answers.add(optionIndex));
    if (_answers.length < kPreAdmissionInstrument.length) return;

    setState(() => _submitting = true);
    final PreAdmissionProfile profile = await widget.repository.submitPreAdmission(
      studentId: widget.studentId,
      schoolId: widget.schoolId,
      answers: _answers,
    );
    if (mounted) widget.onComplete(profile);
  }

  void _back() {
    if (_answers.isEmpty) return;
    setState(() => _answers.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final int total = kPreAdmissionInstrument.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-admission Test'),
        automaticallyImplyLeading: false,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    LinearProgressIndicator(value: _index / total),
                    const SizedBox(height: 8),
                    Text(
                      'Question ${_index + 1} of $total',
                      key: const Key('pre-admission-progress'),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(_question.theme,
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 16),
                    Text(_question.prompt,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          for (int i = 0; i < _question.options.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OutlinedButton(
                                key: Key('pre-admission-option-$i'),
                                onPressed: () => _choose(i),
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: Text(_question.options[i].text),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_answers.isNotEmpty)
                      TextButton(
                        key: const Key('pre-admission-back'),
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
