/// The enumerated constraint that stops the model inventing a label.
///
/// Verified live against gemini-2.5-flash: a STRING property carrying `enum`
/// is honoured, so a question cannot cite a slug outside the chapter's set.
/// The composite foreign key in Postgres is the second line of defence.
export const microSkillEnum = (slugs: string[]) => ({
  type: "STRING",
  enum: slugs,
});

export const knowledgePackSchema = () => ({
  type: "OBJECT",
  properties: {
    concepts: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          name: { type: "STRING" },
          summary: { type: "STRING" },
        },
        required: ["name", "summary"],
        propertyOrdering: ["name", "summary"],
      },
    },
    definitions: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: { term: { type: "STRING" }, meaning: { type: "STRING" } },
        required: ["term", "meaning"],
        propertyOrdering: ["term", "meaning"],
      },
    },
    formulas: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: { name: { type: "STRING" }, expression: { type: "STRING" } },
        required: ["name", "expression"],
        propertyOrdering: ["name", "expression"],
      },
    },
    worked_examples: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: { problem: { type: "STRING" }, solution: { type: "STRING" } },
        required: ["problem", "solution"],
        propertyOrdering: ["problem", "solution"],
      },
    },
    difficulty_markers: { type: "ARRAY", items: { type: "STRING" } },
    source_refs: { type: "ARRAY", items: { type: "STRING" } },
    micro_skills: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          slug: { type: "STRING" },
          label: { type: "STRING" },
          description: { type: "STRING" },
        },
        required: ["slug", "label", "description"],
        propertyOrdering: ["slug", "label", "description"],
      },
    },
  },
  required: [
    "concepts", "definitions", "formulas",
    "worked_examples", "difficulty_markers", "source_refs", "micro_skills",
  ],
  propertyOrdering: [
    "concepts", "definitions", "formulas",
    "worked_examples", "difficulty_markers", "source_refs", "micro_skills",
  ],
});

export const questionBatchSchema = (slugs: string[]) => ({
  type: "ARRAY",
  items: {
    type: "OBJECT",
    properties: {
      stem: { type: "STRING" },
      options: {
        type: "ARRAY",
        items: { type: "STRING" },
        minItems: 4,
        maxItems: 4,
      },
      correct_index: { type: "INTEGER" },
      rationale: { type: "STRING" },
      micro_skill: microSkillEnum(slugs),
    },
    required: ["stem", "options", "correct_index", "rationale", "micro_skill"],
    propertyOrdering: [
      "stem", "options", "correct_index", "rationale", "micro_skill",
    ],
  },
});

export const classSummarySchema = () => ({
  type: "OBJECT",
  properties: {
    summary: { type: "STRING" },
  },
  required: ["summary"],
  propertyOrdering: ["summary"],
});

/// The six conversational tool names, mirrored from `kToolNames` in
/// `packages/syncedu_core/lib/src/tools/tool_call.dart`. A rename on one side
/// and not the other silently breaks voice; the seam test asserts these two
/// sets are equal.
export const kToolNames: Set<string> = new Set([
  "start_quiz",
  "open_flashcards",
  "open_story",
  "generate_notes",
  "show_progress",
  "pick_chapter",
]);

/// The six conversational tools, declared to Gemini.
///
/// `chapter_ordinals` / `chapter_ordinal` are STRING enums constrained to the
/// ordinals the student was actually offered, so the model cannot route to a
/// chapter that does not exist. The handler coerces the strings back to
/// numbers before returning.
export const chatToolDeclarations = (ordinals: number[]) => {
  const asStrings = ordinals.map((n) => String(n));
  const ordinalEnum = { type: "STRING", enum: asStrings };
  return [
    {
      name: "start_quiz",
      description:
        "Start a practice quiz over one or more chapters. Use when the " +
        "student asks to be quizzed, tested, or to practise a chapter.",
      parameters: {
        type: "OBJECT",
        properties: {
          chapter_ordinals: { type: "ARRAY", items: ordinalEnum },
          question_count: {
            type: "INTEGER",
            description: "How many questions. Defaults to 10 if unstated.",
          },
        },
        required: ["chapter_ordinals"],
      },
    },
    {
      name: "open_flashcards",
      description: "Open flashcards for one chapter.",
      parameters: {
        type: "OBJECT",
        properties: { chapter_ordinal: ordinalEnum },
        required: ["chapter_ordinal"],
      },
    },
    {
      name: "open_story",
      description: "Open the story for one chapter.",
      parameters: {
        type: "OBJECT",
        properties: { chapter_ordinal: ordinalEnum },
        required: ["chapter_ordinal"],
      },
    },
    {
      name: "generate_notes",
      description:
        "Generate targeted notes. A chapter is optional; without one, " +
        "notes cover the student's current weak spots.",
      parameters: {
        type: "OBJECT",
        properties: { chapter_ordinal: ordinalEnum },
        required: [],
      },
    },
    {
      name: "show_progress",
      description: "Show the student their progress and struggle tags.",
      parameters: { type: "OBJECT", properties: {} },
    },
    {
      name: "pick_chapter",
      description: "Open the chapter picker so the student can choose a range.",
      parameters: { type: "OBJECT", properties: {} },
    },
  ];
};

/// A flashcard deck. Every card cites a micro-skill of its chapter under the
/// same enumerated constraint as question generation, and names the concept it
/// covers so the UI can label it.
export const flashcardDeckSchema = (slugs: string[]) => ({
  type: "OBJECT",
  properties: {
    cards: {
      type: "ARRAY",
      minItems: 15,
      maxItems: 30,
      items: {
        type: "OBJECT",
        properties: {
          front: { type: "STRING" },
          back: { type: "STRING" },
          concept: { type: "STRING" },
          micro_skill: microSkillEnum(slugs),
        },
        required: ["front", "back", "concept", "micro_skill"],
        propertyOrdering: ["front", "back", "concept", "micro_skill"],
      },
    },
  },
  required: ["cards"],
  propertyOrdering: ["cards"],
});

/// A typographic story: ordered scenes, each a caption and a longer
/// description. `gemini-2.5-flash` generates no images, so a scene is text
/// laid out well, not a picture. `concepts` lists the chapter concepts the
/// story teaches, so the UI can show what was covered.
export const storySchema = () => ({
  type: "OBJECT",
  properties: {
    title: { type: "STRING" },
    concepts: { type: "ARRAY", items: { type: "STRING" } },
    scenes: {
      type: "ARRAY",
      minItems: 4,
      maxItems: 10,
      items: {
        type: "OBJECT",
        properties: {
          caption: { type: "STRING" },
          description: { type: "STRING" },
        },
        required: ["caption", "description"],
        propertyOrdering: ["caption", "description"],
      },
    },
  },
  required: ["title", "concepts", "scenes"],
  propertyOrdering: ["title", "concepts", "scenes"],
});

/// Bespoke targeted notes: an ordered set of sections, each headed by the
/// micro-skill it covers.
export const notesSchema = (slugs: string[]) => ({
  type: "OBJECT",
  properties: {
    sections: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          micro_skill: microSkillEnum(slugs),
          heading: { type: "STRING" },
          body: { type: "STRING" },
        },
        required: ["micro_skill", "heading", "body"],
        propertyOrdering: ["micro_skill", "heading", "body"],
      },
    },
  },
  required: ["sections"],
  propertyOrdering: ["sections"],
});

/// One rationale sentence per placement suggestion, keyed by the student id it
/// belongs to so the handler can match prose back to the deterministic
/// assignment without trusting order.
export const placementRationalesSchema = (studentIds: string[]) => ({
  type: "OBJECT",
  properties: {
    rationales: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          student_id: { type: "STRING", enum: studentIds },
          rationale: { type: "STRING" },
        },
        required: ["student_id", "rationale"],
        propertyOrdering: ["student_id", "rationale"],
      },
    },
  },
  required: ["rationales"],
  propertyOrdering: ["rationales"],
});

/// The observation score and recommendation prose `analyse-fit` asks Gemini
/// for. `teacher_pct` is the only number the model produces; the 40/30/30
/// composition is done in Dart.
export const fitObservationSchema = () => ({
  type: "OBJECT",
  properties: {
    teacher_pct: { type: "NUMBER" },
    recommendation: { type: "STRING" },
  },
  required: ["teacher_pct", "recommendation"],
  propertyOrdering: ["teacher_pct", "recommendation"],
});

/// Exam-paper analysis: per micro-skill of the chapter, how many marks the
/// student attempted and how many they got wrong. Mapped onto the chapter's
/// EXISTING slugs under the same enumerated constraint as question
/// generation — no parallel taxonomy.
export const examAnalysisSchema = (slugs: string[]) => ({
  type: "OBJECT",
  properties: {
    skills: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          micro_skill: microSkillEnum(slugs),
          questions_seen: { type: "INTEGER" },
          questions_wrong: { type: "INTEGER" },
        },
        required: ["micro_skill", "questions_seen", "questions_wrong"],
        propertyOrdering: ["micro_skill", "questions_seen", "questions_wrong"],
      },
    },
  },
  required: ["skills"],
  propertyOrdering: ["skills"],
});

/// The teaching review: prose about figures the console already computed,
/// plus a re-teach deck for the flagged micro-skills.
///
/// `micro_skill` is enumerated to the FLAGGED slugs rather than the whole
/// chapter's, so the model cannot quietly widen a re-teach deck into a
/// chapter rewrite -- the deck is meant to cover what did not land, and
/// nothing else. No number appears anywhere in this schema: every figure the
/// prose cites was handed to the model by the caller.
export const teachingReviewSchema = (slugs: string[]) => ({
  type: "OBJECT",
  properties: {
    summary: { type: "STRING" },
    actions: {
      type: "ARRAY",
      minItems: 2,
      maxItems: 6,
      items: {
        type: "OBJECT",
        properties: {
          micro_skill: microSkillEnum(slugs),
          title: { type: "STRING" },
          detail: { type: "STRING" },
        },
        required: ["micro_skill", "title", "detail"],
        propertyOrdering: ["micro_skill", "title", "detail"],
      },
    },
    deck_title: { type: "STRING" },
    slides: {
      type: "ARRAY",
      minItems: 6,
      maxItems: 16,
      items: {
        type: "OBJECT",
        properties: {
          micro_skill: microSkillEnum(slugs),
          title: { type: "STRING" },
          bullets: {
            type: "ARRAY",
            items: { type: "STRING" },
            minItems: 1,
            maxItems: 6,
          },
          notes: { type: "STRING" },
        },
        required: ["micro_skill", "title", "bullets", "notes"],
        propertyOrdering: ["micro_skill", "title", "bullets", "notes"],
      },
    },
  },
  required: ["summary", "actions", "deck_title", "slides"],
  propertyOrdering: ["summary", "actions", "deck_title", "slides"],
});

export const explanationBatchSchema = (slugs: string[]) => ({
  type: "ARRAY",
  items: {
    type: "OBJECT",
    properties: {
      micro_skill: microSkillEnum(slugs),
      body: { type: "STRING" },
    },
    required: ["micro_skill", "body"],
    propertyOrdering: ["micro_skill", "body"],
  },
});
