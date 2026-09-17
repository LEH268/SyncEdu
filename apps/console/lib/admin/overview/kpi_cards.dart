import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders the four top-level school KPIs.
///
/// This widget never computes a figure: every number it shows comes
/// straight from the [SchoolKpis] passed in.
class KpiCards extends StatelessWidget {
  const KpiCards({super.key, required this.kpis});

  final SchoolKpis kpis;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        _KpiCard(label: 'Students', value: '${kpis.totalStudents}'),
        _KpiCard(label: 'Teachers', value: '${kpis.totalTeachers}'),
        _KpiCard(label: 'Students at risk', value: '${kpis.studentsAtRisk}'),
        _KpiCard(
          label: 'Average mastery',
          value: '${(kpis.averageMastery * 100).round()}%',
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
