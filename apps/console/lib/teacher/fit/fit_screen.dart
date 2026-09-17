import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import 'fit_repository.dart';

/// The Class Fit Analyzer for one student. Every number here is composed in
/// Dart (`composeFitScore`); the model only scores the observation text and
/// writes the recommendation, and the screen labels which path ran.
class FitScreen extends StatefulWidget {
  const FitScreen({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.studentId,
  });

  final FitRepository repository;
  final String schoolId;
  final String studentId;

  @override
  State<FitScreen> createState() => _FitScreenState();
}

class _FitScreenState extends State<FitScreen> {
  final TextEditingController _observation = TextEditingController();
  late final Future<FitInputs> _inputs = _loadInputs();
  FitInputs? _loaded;
  FitResult? _result;
  bool _running = false;

  Future<FitInputs> _loadInputs() async {
    final FitInputs inputs = await widget.repository.inputsFor(widget.studentId);
    _observation.text = inputs.latestObservation ?? '';
    _loaded = inputs;
    return inputs;
  }

  @override
  void dispose() {
    _observation.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final FitInputs? inputs = _loaded;
    if (inputs == null) return;
    setState(() => _running = true);
    final FitResult result = await widget.repository.analyse(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      observationText: _observation.text.trim(),
      academicPct: inputs.academicPct,
      studentPct: inputs.studentPct,
    );
    setState(() {
      _result = result;
      _running = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Fit Analyzer')),
      body: FutureBuilder<FitInputs>(
        future: _inputs,
        builder: (BuildContext context, AsyncSnapshot<FitInputs> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final FitInputs inputs = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(inputs.studentName,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Academic result: ${_pct(inputs.academicPct)}   ·   '
                  'Student reflection: ${_pct(inputs.studentPct)}'),
              const SizedBox(height: 16),
              TextField(
                key: const Key('fit-observation'),
                controller: _observation,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Teacher observation (scored for the 30% component)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('fit-analyse'),
                onPressed: _running || _observation.text.trim().isEmpty
                    ? null
                    : _run,
                child: Text(_running ? 'Analysing…' : 'Analyse fit'),
              ),
              const SizedBox(height: 24),
              if (_result != null) _resultCard(context, _result!),
            ],
          );
        },
      ),
    );
  }

  Widget _resultCard(BuildContext context, FitResult result) {
    final FitScore score = result.score;
    return Card(
      key: const Key('fit-result'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  score.score == null
                      ? 'No score'
                      : 'Fit score ${score.score!.toStringAsFixed(1)} / 100',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 12),
                if (score.verdict != null)
                  Chip(label: Text(_verdictLabel(score.verdict!))),
              ],
            ),
            const SizedBox(height: 8),
            Text('Composition (40 / 30 / 30):',
                style: Theme.of(context).textTheme.labelLarge),
            Text('• Academic  ${score.academicContribution.toStringAsFixed(1)}'),
            Text('• Student   ${score.studentContribution.toStringAsFixed(1)}'),
            Text('• Teacher   ${score.teacherContribution.toStringAsFixed(1)}'),
            if (score.componentsUsed.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Reweighted around missing: '
                  '${<String>['academic', 'student', 'teacher'].where((c) => !score.componentsUsed.contains(c)).join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Divider(height: 24),
            Row(
              children: <Widget>[
                Text('Recommendation',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 8),
                Chip(
                  key: const Key('fit-source'),
                  label: Text(result.source == 'ai'
                      ? 'written by AI'
                      : 'rule-based fallback'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(result.recommendation),
          ],
        ),
      ),
    );
  }
}

String _pct(double? v) => v == null ? 'n/a' : '${v.toStringAsFixed(0)}%';

String _verdictLabel(FitVerdict v) => switch (v) {
      FitVerdict.greatFit => 'Great fit',
      FitVerdict.acceptable => 'Acceptable',
      FitVerdict.mismatch => 'Mismatch',
      FitVerdict.strongMismatch => 'Strong mismatch',
    };
