import 'dart:convert';

/// The kinds of generated revision content, matching
/// `generated_content.kind`.
enum ContentKind { notes, flashcards, story }

extension ContentKindName on ContentKind {
  String get wire => switch (this) {
        ContentKind.notes => 'notes',
        ContentKind.flashcards => 'flashcards',
        ContentKind.story => 'story',
      };
}

class Flashcard {
  const Flashcard({required this.front, required this.back, required this.concept});

  final String front;
  final String back;
  final String concept;
}

class FlashcardDeck {
  const FlashcardDeck(this.cards);

  final List<Flashcard> cards;

  static FlashcardDeck fromPayload(String payloadJson) {
    final Map<String, dynamic> payload =
        (jsonDecode(payloadJson) as Map<dynamic, dynamic>).cast<String, dynamic>();
    final List<dynamic> raw = (payload['cards'] as List<dynamic>?) ?? <dynamic>[];
    return FlashcardDeck(<Flashcard>[
      for (final dynamic c in raw)
        Flashcard(
          front: (c as Map<dynamic, dynamic>)['front'] as String? ?? '',
          back: c['back'] as String? ?? '',
          concept: c['concept'] as String? ?? '',
        ),
    ]);
  }
}

class StoryScene {
  const StoryScene({required this.caption, required this.description});

  final String caption;
  final String description;
}

class Story {
  const Story({
    required this.title,
    required this.concepts,
    required this.scenes,
    required this.mode,
  });

  final String title;
  final List<String> concepts;
  final List<StoryScene> scenes;

  /// 'prep' or 'revise' — prep stories are gentler.
  final String mode;

  static Story fromPayload(String payloadJson) {
    final Map<String, dynamic> payload =
        (jsonDecode(payloadJson) as Map<dynamic, dynamic>).cast<String, dynamic>();
    return Story(
      title: payload['title'] as String? ?? 'Story',
      concepts: <String>[
        for (final dynamic c in (payload['concepts'] as List<dynamic>?) ?? <dynamic>[])
          c.toString(),
      ],
      scenes: <StoryScene>[
        for (final dynamic s in (payload['scenes'] as List<dynamic>?) ?? <dynamic>[])
          StoryScene(
            caption: (s as Map<dynamic, dynamic>)['caption'] as String? ?? '',
            description: s['description'] as String? ?? '',
          ),
      ],
      mode: payload['mode'] as String? ?? 'revise',
    );
  }
}
