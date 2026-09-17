import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import 'deck_download.dart';
import 'pptx_writer.dart';
import 'teaching_repository.dart';

/// The teaching review tab.
///
/// A teacher picks a class and a chapter they have taught it, and is shown
/// which micro-skills did not land, whether the same skills also failed in
/// their other classes, and the wrong answers students actually chose. From
/// there they generate improvement advice and a re-teach deck, exported as a
/// `.pptx` they can edit.
///
/// Every figure on this screen comes from `reviewTeaching`; the model is only
/// ever handed those figures and asked to write about them, and the screen
/// says which of the two wrote the summary it is showing.
class TeachingScreen extends StatefulWidget {
  const TeachingScreen({
    super.key,
    required this.repository,
    required this.schoolId,
    this.download = downloadBytes,
  });

  final TeachingRepository repository;
  final String schoolId;

  /// Injected so a test can assert a deck was handed over without a browser.
  final Future<void> Function(Uint8List bytes, String filename, String mimeType)
      download;

  @override
  State<TeachingScreen> createState() => _TeachingScreenState();
}

class _TeachingScreenState extends State<TeachingScreen> {
  late final Future<List<TeachableChapter>> _options =
      widget.repository.teachableChapters();
  TeachableChapter? _selected;
  TeachingReview? _review;
  TeachingInsight? _insight;
  bool _loading = false;
  bool _generating = false;
  String? _error;

  Future<void> _select(TeachableChapter option) async {
    setState(() {
      _selected = option;
      _review = null;
      _insight = null;
      _loading = true;
      _error = null;
    });
    final TeachingReview review = await widget.repository.review(
      classId: option.classId,
      chapterId: option.chapterId,
    );
    // A review saved earlier is shown straight away, with no model call: this
    // is the whole reason the table is mirrored locally.
    final TeachingInsight? saved = await widget.repository.latest(
      classId: option.classId,
      chapterId: option.chapterId,
      review: review,
    );
    if (!mounted) return;
    setState(() {
      _review = review;
      _insight = saved;
      _loading = false;
    });
  }

  Future<void> _generate() async {
    final TeachingReview? review = _review;
    if (review == null || !review.hasFindings) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final TeachingInsight insight = await widget.repository.generate(
        schoolId: widget.schoolId,
        review: review,
      );
      if (!mounted) return;
      setState(() {
        _insight = insight;
        _generating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = 'Could not save this review: $error';
      });
    }
  }

  Future<void> _export() async {
    final TeachingInsight? insight = _insight;
    if (insight == null) return;
    try {
      await widget.download(
        insight.toPptx(),
        insight.filename,
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not export the deck: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeachableChapter>>(
      future: _options,
      builder: (BuildContext context,
          AsyncSnapshot<List<TeachableChapter>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<TeachableChapter> options =
            snapshot.data ?? const <TeachableChapter>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Teaching review',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text(
              'Where a chapter did not land, and whether the evidence points '
              'at the class or at how the material presents the skill.',
            ),
            const SizedBox(height: 16),
            if (options.isEmpty)
              const Card(
                key: Key('teaching-no-chapters'),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No chapter of yours has been marked as taught yet. Set a '
                    'taught date on the Schedule tab first: a class failing a '
                    'chapter nobody has taught them says nothing about how it '
                    'was presented.',
                  ),
                ),
              )
            else
              _picker(options),
            if (_loading) ...<Widget>[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                _error!,
                key: const Key('teaching-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_review != null && !_loading) ...<Widget>[
              const SizedBox(height: 24),
              _findings(context, _review!),
              const SizedBox(height: 16),
              _actionsRow(context, _review!),
              if (_insight != null) ...<Widget>[
                const SizedBox(height: 24),
                _summaryCard(context, _insight!),
                const SizedBox(height: 16),
                _deckCard(context, _insight!),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _picker(List<TeachableChapter> options) {
    return DropdownButtonFormField<TeachableChapter>(
      key: const Key('teaching-picker'),
      initialValue: _selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Class and chapter',
        border: OutlineInputBorder(),
      ),
      items: options
          .map((TeachableChapter option) =>
              DropdownMenuItem<TeachableChapter>(
                value: option,
                child: Text(option.label, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (TeachableChapter? option) {
        if (option != null) _select(option);
      },
    );
  }

  Widget _findings(BuildContext context, TeachingReview review) {
    if (!review.hasFindings) {
      return Card(
        key: const Key('teaching-clear'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(review.ruleHeadline),
        ),
      );
    }
    return Column(
      key: const Key('teaching-findings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(review.ruleHeadline,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        for (final TeachingSignal signal in review.signals)
          _signalCard(context, signal),
      ],
    );
  }

  Widget _signalCard(BuildContext context, TeachingSignal signal) {
    final (String label, Color color) = switch (signal.scope) {
      TeachingScope.materialWide => (
          'Fails in your other classes too',
          Theme.of(context).colorScheme.error,
        ),
      TeachingScope.classSpecific => (
          'Specific to this class',
          Theme.of(context).colorScheme.tertiary,
        ),
      TeachingScope.insufficientComparison => (
          'No comparison available',
          Theme.of(context).colorScheme.outline,
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    signal.microSkillLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(label, style: const TextStyle(fontSize: 11)),
                  side: BorderSide(color: color),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(signal.sentence),
            if (signal.misconceptions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text('What they chose instead',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              for (final Misconception m in signal.misconceptions)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${m.studentCount} chose "${m.optionText}" '
                    'on "${m.questionStem}"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionsRow(BuildContext context, TeachingReview review) {
    if (!review.hasFindings) return const SizedBox.shrink();
    return Row(
      children: <Widget>[
        FilledButton.icon(
          key: const Key('teaching-generate'),
          onPressed: _generating ? null : _generate,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: Text(_generating
              ? 'Working…'
              : _insight == null
                  ? 'Write advice and build a re-teach deck'
                  : 'Regenerate'),
        ),
        const SizedBox(width: 12),
        if (_insight != null)
          OutlinedButton.icon(
            key: const Key('teaching-export'),
            onPressed: _export,
            icon: const Icon(Icons.slideshow, size: 18),
            label: const Text('Export .pptx'),
          ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, TeachingInsight insight) {
    return Card(
      key: const Key('teaching-summary'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  insight.source == 'ai' ? Icons.auto_awesome : Icons.rule,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  insight.source == 'ai'
                      ? 'AI summary, written from the figures above'
                      : 'Rule-based summary — the model was unreachable',
                  key: const Key('teaching-summary-source'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(insight.summary, key: const Key('teaching-summary-text')),
            if (insight.actions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text('What to change',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              for (final TeachingAction action in insight.actions)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(action.title,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(action.detail),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _deckCard(BuildContext context, TeachingInsight insight) {
    final DeckSpec deck = insight.deck;
    return Card(
      key: const Key('teaching-deck'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(deck.title, style: Theme.of(context).textTheme.titleMedium),
            Text(deck.subtitle,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            // The preview is the same DeckSpec the .pptx is written from, so
            // what a teacher sees here is what opens in PowerPoint.
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: deck.slides.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) =>
                    _slidePreview(context, index + 1, deck.slides[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slidePreview(BuildContext context, int number, SlideSpec slide) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Slide $number',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(slide.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (final String bullet in slide.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('•  $bullet',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                if (slide.notes.trim().isNotEmpty) ...<Widget>[
                  const Divider(height: 16),
                  Text('Notes: ${slide.notes}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
