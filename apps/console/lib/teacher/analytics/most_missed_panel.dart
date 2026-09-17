import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-ranked list of most-missed concepts for a class.
///
/// This widget never computes an error rate: it only formats the
/// [ConceptRank.errorRate] and [ConceptRank.total] it is given.
class MostMissedPanel extends StatelessWidget {
  const MostMissedPanel({super.key, required this.ranked});

  final List<ConceptRank> ranked;

  @override
  Widget build(BuildContext context) {
    if (ranked.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No missed concepts to show yet. This list fills in once enough '
          'students have attempted a skill.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: ranked.length,
      itemBuilder: (BuildContext context, int index) {
        final ConceptRank rank = ranked[index];
        final int percent = (rank.errorRate * 100).round();
        return ListTile(
          title: Text(rank.microSkillLabel),
          trailing: Text('$percent% missed (n=${rank.total})'),
        );
      },
    );
  }
}
