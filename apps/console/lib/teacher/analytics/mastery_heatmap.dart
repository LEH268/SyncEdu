import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-computed mastery heatmap for one class.
///
/// This widget never computes an accuracy or a band itself: every colour and
/// figure it shows comes straight from the [MasteryCell]/[SkillCell] passed
/// in. In particular, [MasteryBand.insufficient] is rendered as literal text
/// ("Not enough data") rather than any colour, because a sample too small to
/// judge must never look like a confident red.
class MasteryHeatmap extends StatelessWidget {
  const MasteryHeatmap({super.key, required this.cells});

  final List<MasteryCell> cells;

  static Color _bandColor(BuildContext context, MasteryBand band) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (band) {
      case MasteryBand.green:
        return Colors.green;
      case MasteryBand.amber:
        return Colors.amber;
      case MasteryBand.red:
        return scheme.error;
      case MasteryBand.insufficient:
        return scheme.surfaceContainerHighest;
    }
  }

  static String _bandLabel(MasteryBand band, double accuracy) {
    if (band == MasteryBand.insufficient) {
      return 'Not enough data';
    }
    return '${(accuracy * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _Legend(),
        const SizedBox(height: 8),
        if (cells.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No mastery data yet for this class. Once students answer '
              'revise-mode questions, chapter accuracy will appear here.',
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 260,
                child: ListView.builder(
                  itemCount: cells.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _ChapterRow(cell: cells[index]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Green: 75% and above. Amber: 50% to 74%. Red: below 50%. '
        'Not enough data: too few answers to judge.',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

class _ChapterRow extends StatefulWidget {
  const _ChapterRow({required this.cell});

  final MasteryCell cell;

  @override
  State<_ChapterRow> createState() => _ChapterRowState();
}

class _ChapterRowState extends State<_ChapterRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final MasteryCell cell = widget.cell;
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Icon(_expanded ? Icons.expand_more : Icons.chevron_right),
                  Container(
                    key: Key('mastery-band-${cell.chapterId}'),
                    width: 16,
                    height: 16,
                    color: MasteryHeatmap._bandColor(context, cell.band),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cell.chapterTitle, overflow: TextOverflow.ellipsis),
                  ),
                  Flexible(
                    child: Text(
                      MasteryHeatmap._bandLabel(cell.band, cell.accuracy),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cell.skills
                    .map(
                      (SkillCell skill) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(skill.microSkillLabel)),
                            Text('${(skill.accuracy * 100).round()}%'),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
