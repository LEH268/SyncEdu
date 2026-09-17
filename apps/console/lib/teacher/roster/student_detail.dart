import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-computed student progress picture: the chronological
/// progress curve, retry chains grouped by lineage, and the student's top
/// struggle tags.
///
/// Nothing here is computed by the widget -- [progress], [retryChains] and
/// [struggleTags] all come straight from `syncedu_core`'s
/// `progressCurve`/`retryChains`/`topStruggleTags`, in the order those
/// functions already return them.
class StudentDetail extends StatelessWidget {
  const StudentDetail({
    super.key,
    required this.progress,
    required this.retryChains,
    required this.struggleTags,
  });

  final List<ProgressPoint> progress;
  final List<RetryChain> retryChains;
  final List<ConceptRank> struggleTags;

  @override
  Widget build(BuildContext context) {
    if (progress.isEmpty && retryChains.isEmpty && struggleTags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No attempts recorded yet for this student. Once they answer '
          'their first quiz, progress will appear here.',
        ),
      );
    }

    return ListView(
      key: const Key('student-detail'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _ProgressCurve(points: progress),
        const SizedBox(height: 24),
        const Text('Retry chains',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (retryChains.isEmpty)
          const Text('No retries recorded yet.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < retryChains.length; i++)
                Padding(
                  key: Key('retry-chain-$i'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RetryChainRow(chain: retryChains[i]),
                ),
            ],
          ),
        const SizedBox(height: 24),
        const Text('Top struggle areas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (struggleTags.isEmpty)
          const Text('No struggle areas identified yet.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: struggleTags
                .map((ConceptRank tag) => _StruggleTagRow(tag: tag))
                .toList(),
          ),
      ],
    );
  }
}

/// A left-to-right timeline of the student's progress points, in the exact
/// order they arrive -- `progressCurve` already sorts oldest first, so this
/// widget must not reorder them.
class _ProgressCurve extends StatelessWidget {
  const _ProgressCurve({required this.points});

  final List<ProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Text('No attempts recorded yet.');
    }
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          key: const Key('progress-curve'),
          children: <Widget>[
            for (final ProgressPoint point in points)
              Padding(
                key: Key('progress-point-${point.attemptId}'),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${(point.proportion * 100).round()}%'),
              ),
          ],
        ),
      ),
    );
  }
}

/// One retry chain, drawn as points joined by connecting segments -- a
/// teacher must be able to see whether targeted practice worked, which
/// scattered, unconnected points cannot show (Requirement 45). A chain of a
/// single point (an attempt with no retry yet) has no segment to draw.
class _RetryChainRow extends StatelessWidget {
  const _RetryChainRow({required this.chain});

  final RetryChain chain;

  @override
  Widget build(BuildContext context) {
    final List<ProgressPoint> points = chain.points;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color lineColor = chain.improved ? Colors.green : scheme.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < points.length; i++) ...<Widget>[
          Column(
            children: <Widget>[
              Container(
                key: Key('retry-point-${points[i].attemptId}'),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lineColor,
                ),
              ),
              Text('${(points[i].proportion * 100).round()}%'),
            ],
          ),
          if (i < points.length - 1)
            Container(
              key: Key('retry-segment-${points[i].attemptId}-${points[i + 1].attemptId}'),
              width: 32,
              height: 3,
              color: lineColor,
            ),
        ],
        const SizedBox(width: 8),
        Text(chain.improved ? 'Improved' : 'Did not improve'),
      ],
    );
  }
}

class _StruggleTagRow extends StatelessWidget {
  const _StruggleTagRow({required this.tag});

  final ConceptRank tag;

  @override
  Widget build(BuildContext context) {
    final bool isQuiz = tag.source == 'quiz';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(tag.microSkillLabel)),
          Text(isQuiz ? '(quiz)' : '(${tag.source})'),
        ],
      ),
    );
  }
}
