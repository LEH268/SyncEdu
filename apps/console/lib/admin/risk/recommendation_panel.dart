import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-ranked list of resource allocation recommendations.
///
/// This panel never composes its own wording for a recommendation: it
/// renders [ResourceRecommendation.sentence] verbatim, so the words a
/// reader sees and the numbers the rule fired on can never drift apart.
/// The one piece of text this widget does build itself is the rule
/// description, and even that is assembled from [AnalyticsThresholds]
/// values rather than hardcoded, so it tracks the thresholds actually in
/// force.
class RecommendationPanel extends StatelessWidget {
  const RecommendationPanel({
    super.key,
    required this.recommendations,
    required this.thresholds,
  });

  final List<ResourceRecommendation> recommendations;
  final AnalyticsThresholds thresholds;

  String get _ruleText {
    final int percent = (thresholds.recommendationProportion * 100).round();
    return 'Rule: $percent% or more of a class struggling on one '
        'micro-skill, class size at least '
        '${thresholds.recommendationMinimumClassSize}.';
  }

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No class currently meets the threshold.'),
            const SizedBox(height: 4),
            Text(_ruleText),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: recommendations.length,
      itemBuilder: (BuildContext context, int index) {
        final ResourceRecommendation recommendation = recommendations[index];
        return ListTile(
          title: Text(recommendation.sentence),
          subtitle: Text(_ruleText),
        );
      },
    );
  }
}
