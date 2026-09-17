import 'package:flutter/material.dart';

import '../content_models.dart';
import '../readable.dart';

/// Shows a story as a sequence of scenes, one at a time, navigable forwards
/// and backwards. Each scene is a caption and a longer description laid out as
/// a styled panel — `gemini-2.5-flash` generates no pictures, and the UI says
/// so rather than implying one is coming.
class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    required this.story,
    this.specialNeeds = const <String>[],
  });

  final Story story;
  final List<String> specialNeeds;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _scene = 0;

  @override
  Widget build(BuildContext context) {
    final Story story = widget.story;
    final List<StoryScene> scenes = story.scenes;
    final bool empty = scenes.isEmpty;
    final StoryScene? current = empty ? null : scenes[_scene];

    return ReadableRegion(
      specialNeeds: widget.specialNeeds,
      child: Scaffold(
        appBar: AppBar(title: Text(story.title)),
        body: empty
            ? const Center(child: Text('This story has no scenes.'))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  Text(
                    story.mode == 'prep'
                        ? 'A gentle introduction — no need to know this yet.'
                        : 'A revision retelling of what you have learned.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Illustrated in words, not pictures.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Scene ${_scene + 1} of ${scenes.length}',
                      key: const Key('story-position'),
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(current!.caption,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Text(current.description,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        key: const Key('story-back'),
                        onPressed: _scene == 0
                            ? null
                            : () => setState(() => _scene--),
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Back'),
                      ),
                      TextButton.icon(
                        key: const Key('story-next'),
                        onPressed: _scene == scenes.length - 1
                            ? null
                            : () => setState(() => _scene++),
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (story.concepts.isNotEmpty) ...<Widget>[
                    Text('This story teaches:',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final String concept in story.concepts)
                          Chip(label: Text(concept)),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
