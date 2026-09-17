import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-ranked list of school-wide difficult micro-skills.
///
/// This widget never computes a proportion: it only formats the
/// [DifficultyRank.proportion] and student counts it is given. The
/// proportion is always labelled "of students" because it measures the
/// share of students struggling, not the share of answers wrong.
class DifficultyRanking extends StatelessWidget {
  const DifficultyRanking({super.key, required this.ranked});

  final List<DifficultyRank> ranked;

  @override
  Widget build(BuildContext context) {
    if (ranked.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No difficulty data to show yet. This list fills in once enough '
          'students have attempted a skill.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: ranked.length,
      itemBuilder: (BuildContext context, int index) {
        final DifficultyRank rank = ranked[index];
        final int percent = (rank.proportion * 100).round();
        return ListTile(
          title: Text(rank.microSkillLabel),
          subtitle: Text('${rank.chapterTitle} · ${rank.subjectName}'),
          trailing: Text(
            '$percent% of students struggling '
            '(${rank.studentsStruggling} of ${rank.studentsAttempted} students)',
            textAlign: TextAlign.right,
          ),
        );
      },
    );
  }
}
