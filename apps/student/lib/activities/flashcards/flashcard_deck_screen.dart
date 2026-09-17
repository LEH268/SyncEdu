import 'package:flutter/material.dart';

import '../content_models.dart';
import '../readable.dart';

/// Browses a flashcard deck: one card at a time, tap to flip, swipe to
/// advance. Position is always shown. Purely a viewer — the deck is handed in
/// already loaded (from cache or a fresh generation).
class FlashcardDeckScreen extends StatefulWidget {
  const FlashcardDeckScreen({
    super.key,
    required this.deck,
    this.chapterTitle,
    this.specialNeeds = const <String>[],
  });

  final FlashcardDeck deck;
  final String? chapterTitle;
  final List<String> specialNeeds;

  @override
  State<FlashcardDeckScreen> createState() => _FlashcardDeckScreenState();
}

class _FlashcardDeckScreenState extends State<FlashcardDeckScreen> {
  final PageController _pages = PageController();
  int _index = 0;
  final Set<int> _flipped = <int>{};

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Flashcard> cards = widget.deck.cards;
    return ReadableRegion(
      specialNeeds: widget.specialNeeds,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterTitle == null
              ? 'Flashcards'
              : 'Flashcards — ${widget.chapterTitle}'),
        ),
        body: cards.isEmpty
            ? const Center(child: Text('This deck is empty.'))
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Card ${_index + 1} of ${cards.length}',
                      key: const Key('flashcard-position'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: cards.length,
                      onPageChanged: (int i) => setState(() => _index = i),
                      itemBuilder: (BuildContext context, int i) {
                        final Flashcard card = cards[i];
                        final bool showBack = _flipped.contains(i);
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: GestureDetector(
                            key: Key('flashcard-$i'),
                            onTap: () => setState(() {
                              if (!_flipped.add(i)) _flipped.remove(i);
                            }),
                            child: Card(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        card.concept,
                                        key: Key('flashcard-concept-$i'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        showBack ? card.back : card.front,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        showBack ? 'Answer' : 'Tap to reveal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
