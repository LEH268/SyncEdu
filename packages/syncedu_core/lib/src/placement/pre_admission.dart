/// The Pre-admission Test: a fixed twenty-question instrument and its pure
/// scoring.
///
/// The instrument is carried over from the reference's questionnaire — a
/// legitimate reuse, since it is a survey and not artwork. Scoring is pure
/// Dart with no model call, so a new student's first run needs no connectivity
/// (spec §8.1). Placement happens later and admin-side.
///
/// One reference defect is fixed on the way in: the reference shipped an option
/// tagged `Kinesthetic`, which matched no scoring branch and was silently
/// discarded. Every tag here is one of [kScoredTags]; the instrument test
/// enforces it.
library;

/// Every tag the scorer understands. A tag outside this set is a bug in the
/// instrument, not an input to ignore.
const Set<String> kScoredTags = <String>{
  'V', 'A', 'R', 'K',
  'Structured', 'Exploratory',
  'Introvert', 'Extrovert',
  'Impulsivity', 'Reflectivity',
};

/// VARK letters in the order a tie is broken (spec: V, A, R, K).
const List<String> kVarkOrder = <String>['V', 'A', 'R', 'K'];

class PreAdmissionOption {
  const PreAdmissionOption(this.text, this.tags);

  final String text;
  final List<String> tags;
}

class PreAdmissionQuestion {
  const PreAdmissionQuestion({
    required this.theme,
    required this.prompt,
    required this.options,
  });

  final String theme;
  final String prompt;
  final List<PreAdmissionOption> options;
}

/// The scored result of one sitting.
class PreAdmissionProfile {
  const PreAdmissionProfile({
    required this.vark,
    required this.dominantStyle,
    required this.structured,
    required this.exploratory,
    required this.introvert,
    required this.extrovert,
    required this.impulsivity,
    required this.reflectivity,
  });

  /// Raw tallies keyed `V`, `A`, `R`, `K`.
  final Map<String, int> vark;

  /// The highest-scoring VARK letter; ties break in [kVarkOrder].
  final String dominantStyle;

  final int structured;
  final int exploratory;
  final int introvert;
  final int extrovert;
  final int impulsivity;
  final int reflectivity;

  /// The pole of each personality axis, ties resolving to the first-named side.
  String get structuredExploratory =>
      exploratory > structured ? 'Exploratory' : 'Structured';
  String get introvertExtrovert =>
      extrovert > introvert ? 'Extrovert' : 'Introvert';
  String get impulsivityReflectivity =>
      reflectivity > impulsivity ? 'Reflectivity' : 'Impulsivity';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vark': vark,
        'dominant_style': dominantStyle,
        'structured': structured,
        'exploratory': exploratory,
        'introvert': introvert,
        'extrovert': extrovert,
        'impulsivity': impulsivity,
        'reflectivity': reflectivity,
      };
}

/// Tallies [answers] — one chosen option index per question, in order — into a
/// [PreAdmissionProfile].
///
/// Throws [ArgumentError] rather than scoring a partial sitting: an incomplete
/// answer list is a caller bug, and a profile built from it would be a lie.
PreAdmissionProfile scoreInstrument(List<int> answers) {
  if (answers.length != kPreAdmissionInstrument.length) {
    throw ArgumentError.value(
      answers.length,
      'answers',
      'expected exactly ${kPreAdmissionInstrument.length} answers',
    );
  }

  final Map<String, int> vark = <String, int>{'V': 0, 'A': 0, 'R': 0, 'K': 0};
  final Map<String, int> personality = <String, int>{
    'Structured': 0,
    'Exploratory': 0,
    'Introvert': 0,
    'Extrovert': 0,
    'Impulsivity': 0,
    'Reflectivity': 0,
  };

  for (int i = 0; i < answers.length; i++) {
    final PreAdmissionQuestion question = kPreAdmissionInstrument[i];
    final int choice = answers[i];
    if (choice < 0 || choice >= question.options.length) {
      throw ArgumentError.value(
        choice,
        'answers[$i]',
        'not a valid option for question ${i + 1}',
      );
    }
    for (final String tag in question.options[choice].tags) {
      if (vark.containsKey(tag)) {
        vark[tag] = vark[tag]! + 1;
      } else {
        personality[tag] = personality[tag]! + 1;
      }
    }
  }

  return PreAdmissionProfile(
    vark: vark,
    dominantStyle: _dominantVark(vark),
    structured: personality['Structured']!,
    exploratory: personality['Exploratory']!,
    introvert: personality['Introvert']!,
    extrovert: personality['Extrovert']!,
    impulsivity: personality['Impulsivity']!,
    reflectivity: personality['Reflectivity']!,
  );
}

String _dominantVark(Map<String, int> vark) {
  String best = kVarkOrder.first;
  for (final String letter in kVarkOrder) {
    if (vark[letter]! > vark[best]!) best = letter;
  }
  return best;
}

/// The twenty questions, four options each, every option carrying one or more
/// tags from [kScoredTags].
const List<PreAdmissionQuestion> kPreAdmissionInstrument = <PreAdmissionQuestion>[
  PreAdmissionQuestion(
    theme: 'Acquiring New Knowledge',
    prompt:
        'You just bought a complicated new board game. How do you learn the rules?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Read the printed rulebook carefully from start to '
          'finish before touching the pieces.', <String>['R', 'Structured', 'Reflectivity']),
      PreAdmissionOption('Watch an animated tutorial showing how the game is '
          'played.', <String>['V', 'Introvert']),
      PreAdmissionOption('Ask a friend who already knows the game to explain '
          'it to you.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Just set up the board and figure it out as you play '
          'the first round.', <String>['K', 'Exploratory', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Acquiring New Knowledge',
    prompt:
        'You are studying for a major History exam. Which method works best for you?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Redrawing timelines and colour-coding maps of '
          'historical events.', <String>['V', 'Structured']),
      PreAdmissionOption('Listening to a history podcast or discussing the '
          'events with classmates.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Rewriting your textbook notes and summarising '
          'paragraphs.', <String>['R', 'Reflectivity', 'Introvert']),
      PreAdmissionOption('Walking around the room while reciting facts or '
          'acting out the events.', <String>['K', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Acquiring New Knowledge',
    prompt: 'You are visiting a large, unfamiliar city. How do you navigate?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Write down a detailed itinerary with a list of '
          'street names and stops.', <String>['R', 'Structured', 'Reflectivity']),
      PreAdmissionOption('Look at the city map to understand the overall '
          'layout and landmarks.', <String>['V', 'Structured']),
      PreAdmissionOption('Walk around and ask locals for directions when you '
          'need to.', <String>['A', 'Extrovert', 'Exploratory']),
      PreAdmissionOption('Put your phone away and just wander around to see '
          'where you end up.', <String>['K', 'Exploratory', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Acquiring New Knowledge',
    prompt:
        'The teacher introduces a brand new, complex science concept. How do you confirm you understand it?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('You write a detailed summary of the concept in your '
          'notebook.', <String>['R', 'Reflectivity']),
      PreAdmissionOption('You picture the scientific diagram or model in your '
          'head.', <String>['V', 'Introvert']),
      PreAdmissionOption('You try to explain the concept aloud to the person '
          'sitting next to you.', <String>['A', 'Extrovert']),
      PreAdmissionOption('You immediately start an experiment or try solving a '
          'practice question.', <String>['K', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Acquiring New Knowledge',
    prompt: 'How do you prefer to memorise a new password?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Picture the pattern your fingers make on the '
          'keyboard.', <String>['V', 'K']),
      PreAdmissionOption('Repeat the numbers and letters aloud several times.',
          <String>['A', 'Impulsivity']),
      PreAdmissionOption('Write the password down on a piece of paper to lock '
          'it into your memory.', <String>['R', 'Reflectivity']),
      PreAdmissionOption('Break it down into logical blocks to remember it.',
          <String>['Structured', 'Reflectivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Problem Solving & Execution',
    prompt:
        'You have to assemble a new piece of flat-pack furniture. What is your strategy?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Lay out all the parts and follow the instruction '
          'manual step-by-step.', <String>['R', 'Structured', 'Reflectivity']),
      PreAdmissionOption('Look at the picture of the final product and figure '
          'out how it connects.', <String>['V', 'Exploratory']),
      PreAdmissionOption('Assemble it with a friend so you can talk through '
          'the process together.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Start screwing things together immediately and fix '
          'mistakes later.', <String>['K', 'Impulsivity', 'Exploratory']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Problem Solving & Execution',
    prompt:
        'The teacher gives you an open-ended project with no strict rules. What is your reaction?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Great! I love the freedom to experiment and do '
          'whatever I want.', <String>['K', 'Exploratory', 'Impulsivity']),
      PreAdmissionOption('I feel anxious. I prefer having a clear grading '
          'rubric to follow.', <String>['R', 'Structured', 'Reflectivity']),
      PreAdmissionOption('I will form a group immediately so we can brainstorm '
          'ideas together.', <String>['A', 'Extrovert']),
      PreAdmissionOption('I will search for visual examples of what past '
          'students did.', <String>['V', 'Reflectivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Problem Solving & Execution',
    prompt:
        'Your laptop suddenly freezes while you are doing homework. What do you do?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Get frustrated and randomly click the mouse or mash '
          'the keyboard.', <String>['K', 'Impulsivity']),
      PreAdmissionOption('Look up the error code and read tech support forums.',
          <String>['R', 'Structured', 'Introvert']),
      PreAdmissionOption('Call a tech-savvy friend and ask them what to do.',
          <String>['A', 'Extrovert']),
      PreAdmissionOption('Calmly retrace your last few steps to see what '
          'caused the crash.', <String>['V', 'Reflectivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Problem Solving & Execution',
    prompt: 'You are trying to solve a very difficult logic puzzle. What is your approach?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Immediately guess an answer just to see what '
          'happens.', <String>['Impulsivity', 'Exploratory']),
      PreAdmissionOption('Draw a diagram or a chart to map out the clues.',
          <String>['V', 'Reflectivity']),
      PreAdmissionOption('Carefully read the text multiple times and underline '
          'key words.', <String>['R', 'Structured']),
      PreAdmissionOption('Read the puzzle aloud or talk it through with '
          'someone.', <String>['A', 'Extrovert']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Problem Solving & Execution',
    prompt: 'You want to cook a dish you have never made before. How do you do it?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Find a recipe, read the ingredients, and measure '
          'everything exactly.', <String>['R', 'Structured', 'Reflectivity']),
      PreAdmissionOption('Watch a cooking video to see what the dish should '
          'look like.', <String>['V', 'Exploratory']),
      PreAdmissionOption('Call someone to guide you through the steps.',
          <String>['A', 'Extrovert']),
      PreAdmissionOption('Just throw ingredients into the pan based on what '
          'smells and tastes right.', <String>['K', 'Impulsivity', 'Exploratory']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Teamwork & Communication',
    prompt: 'What is your ideal role in a group project?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('The planner: writing the outline and assigning '
          'tasks.', <String>['R', 'Structured']),
      PreAdmissionOption('The designer: creating the slides and formatting the '
          'graphics.', <String>['V', 'Introvert']),
      PreAdmissionOption('The communicator: leading discussions and presenting '
          'to the class.', <String>['A', 'Extrovert']),
      PreAdmissionOption('The doer: building the physical model or running the '
          'experiment.', <String>['K', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Teamwork & Communication',
    prompt: 'When presenting your project to the class, which format do you prefer?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Reading from a well-structured, written script.',
          <String>['R', 'Structured', 'Introvert']),
      PreAdmissionOption('Pointing to charts, graphs, and animations on the '
          'screen.', <String>['V', 'Structured']),
      PreAdmissionOption('Speaking naturally and taking questions from the '
          'crowd.', <String>['A', 'Extrovert', 'Exploratory']),
      PreAdmissionOption('Doing a live demonstration or interactive game with '
          'the audience.', <String>['K', 'Extrovert']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Teamwork & Communication',
    prompt: 'How do you usually express yourself when you are upset with a friend?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Write them a long message explaining exactly why I '
          'am upset.', <String>['R', 'Introvert', 'Reflectivity']),
      PreAdmissionOption('Call them or meet face-to-face to talk it out '
          'immediately.', <String>['A', 'Extrovert', 'Impulsivity']),
      PreAdmissionOption('Give them the silent treatment and show my anger '
          'through facial expressions.', <String>['V', 'Introvert']),
      PreAdmissionOption('Stomp around, slam doors, or go for a run to burn '
          'off the anger.', <String>['K', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Teamwork & Communication',
    prompt: 'If you have to choose a study buddy, who would you pick?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Someone who sits quietly with me in the library '
          'while we read our own books.', <String>['R', 'Introvert']),
      PreAdmissionOption('Someone who quizzes me verbally and discusses topics '
          'with me.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Someone who colour-codes mind maps with me.',
          <String>['V', 'Structured']),
      PreAdmissionOption('Someone who keeps me on a strict timer so I do not '
          'get distracted.', <String>['Structured', 'Reflectivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Teamwork & Communication',
    prompt: 'In a group discussion, what frustrates you the most?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('When people go off-topic and ignore the main '
          'agenda.', <String>['Structured', 'Reflectivity']),
      PreAdmissionOption('When someone stays silent and refuses to share their '
          'opinions.', <String>['Extrovert', 'A']),
      PreAdmissionOption('When it is all talk but nobody actually starts doing '
          'the work.', <String>['K', 'Impulsivity']),
      PreAdmissionOption('When ideas are messy and not written down.',
          <String>['V', 'R']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Environment & Cognitive Pacing',
    prompt: 'The teacher suddenly announces a pop quiz. What is your immediate reaction?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('I scan the whole paper quickly and immediately start '
          'answering the easy ones.', <String>['Impulsivity', 'Exploratory']),
      PreAdmissionOption('I take a deep breath, read the instructions '
          'carefully, and plan my time.', <String>['Reflectivity', 'Structured']),
      PreAdmissionOption('I panic a little and look around to see how my '
          'classmates are reacting.', <String>['Extrovert', 'V']),
      PreAdmissionOption('I tap my pen nervously and just want to get it over '
          'with.', <String>['K', 'Impulsivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Environment & Cognitive Pacing',
    prompt: 'What is your perfect learning environment?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('A completely silent room with blank walls and no '
          'distractions.', <String>['Introvert', 'V']),
      PreAdmissionOption('A cafe or a room where I can play background music.',
          <String>['A', 'Exploratory']),
      PreAdmissionOption('A dynamic space where I can walk around or stand '
          'while working.', <String>['K', 'Exploratory']),
      PreAdmissionOption('A highly organised desk with a clear schedule and a '
          'ticking clock.', <String>['Structured', 'Reflectivity']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Environment & Cognitive Pacing',
    prompt:
        'When answering a multiple-choice question that you are unsure about, you usually:',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Go with your first gut feeling and move on quickly.',
          <String>['Impulsivity', 'Exploratory']),
      PreAdmissionOption('Eliminate the wrong answers one by one until you are '
          'completely sure.', <String>['Reflectivity', 'Structured']),
      PreAdmissionOption('Read the options aloud softly to see which one '
          'sounds right.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Try to visualise the page in the textbook where the '
          'answer was written.', <String>['V', 'Introvert']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Environment & Cognitive Pacing',
    prompt: 'How do you prefer to spend a free weekend?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('Staying home alone to read a book or write in my '
          'journal.', <String>['R', 'Introvert']),
      PreAdmissionOption('Going out with a big group of friends to chat and '
          'hang out.', <String>['A', 'Extrovert']),
      PreAdmissionOption('Watching films, playing video games, or visiting an '
          'art gallery.', <String>['V', 'Introvert']),
      PreAdmissionOption('Trying a new physical activity, like rock climbing '
          'or a dance class.', <String>['K', 'Exploratory']),
    ],
  ),
  PreAdmissionQuestion(
    theme: 'Environment & Cognitive Pacing',
    prompt: 'Be honest: how did you answer these twenty questions?',
    options: <PreAdmissionOption>[
      PreAdmissionOption('I clicked through them as fast as possible without '
          'thinking too much.', <String>['Impulsivity', 'K']),
      PreAdmissionOption('I thought carefully about every single scenario '
          'before choosing.', <String>['Reflectivity', 'Structured']),
      PreAdmissionOption('I imagined the scenes in my head like a film while '
          'answering.', <String>['V', 'Exploratory']),
      PreAdmissionOption('I imagined someone asking me these questions in an '
          'interview.', <String>['A', 'Extrovert']),
    ],
  ),
];
