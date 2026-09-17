/// Initial placement: match a new student's dominant learning style against
/// each class's configured `target_learning_style`, class size as tiebreaker.
///
/// This reads [ClassOption.targetStyle], never [ClassOption.name]. The
/// reference substring-matched the dominant VARK letter against the class
/// *name*, so a class called "Year 1 Alpha" captured every auditory student.
/// The assignment is computed deterministically here; `suggest-placement`
/// receives it and writes only the human-readable rationale.
library;

/// A student awaiting placement. [dominant] is their [PreAdmissionProfile]
/// dominant style, or null when they have not sat the instrument.
class StudentProfile {
  const StudentProfile({required this.id, this.dominant});

  final String id;
  final String? dominant;
}

/// A class a student could be placed into. [size] is its current roll.
class ClassOption {
  const ClassOption({
    required this.id,
    required this.name,
    required this.targetStyle,
    required this.size,
  });

  final String id;
  final String name;

  /// The learning style this class is configured to serve — a VARK letter.
  final String targetStyle;

  /// Current headcount, before this placement run.
  final int size;
}

class PlacementDecision {
  const PlacementDecision({
    required this.studentId,
    required this.classId,
    required this.rationale,
  });

  final String studentId;

  /// Null when the student cannot be placed (no profile, or no classes).
  final String? classId;

  /// The deterministic reason this class (or no class) was chosen. The model
  /// rewrites this into prose server-side; the structure stays.
  final String rationale;
}

/// Places each student in [students], in order, balancing class sizes as it
/// goes so that ten similar students do not all land in the same smallest
/// class.
///
/// Rules, in order:
/// 1. A student with no [StudentProfile.dominant] is left unassigned.
/// 2. With no classes at all, every student is unassigned.
/// 3. Among classes whose [ClassOption.targetStyle] matches the student, the
///    one with the fewest students *so far this run* wins; ties break on class
///    id for determinism.
/// 4. With no style match, the smallest class wins (same tiebreak).
List<PlacementDecision> suggestPlacements({
  required List<StudentProfile> students,
  required List<ClassOption> classes,
}) {
  final Map<String, int> running = <String, int>{
    for (final ClassOption c in classes) c.id: c.size,
  };

  final List<PlacementDecision> out = <PlacementDecision>[];

  for (final StudentProfile student in students) {
    if (student.dominant == null || student.dominant!.isEmpty) {
      out.add(PlacementDecision(
        studentId: student.id,
        classId: null,
        rationale: 'No Pre-admission profile on file; left for manual '
            'placement rather than guessed.',
      ));
      continue;
    }
    if (classes.isEmpty) {
      out.add(PlacementDecision(
        studentId: student.id,
        classId: null,
        rationale: 'No classes are configured to place into.',
      ));
      continue;
    }

    final String style = student.dominant!;
    final List<ClassOption> matching = classes
        .where((ClassOption c) => c.targetStyle == style)
        .toList();
    final bool styleMatched = matching.isNotEmpty;
    final List<ClassOption> pool = styleMatched ? matching : classes;

    final ClassOption chosen = pool.reduce((ClassOption a, ClassOption b) {
      final int byCount = running[a.id]!.compareTo(running[b.id]!);
      if (byCount != 0) return byCount < 0 ? a : b;
      return a.id.compareTo(b.id) <= 0 ? a : b;
    });

    running[chosen.id] = running[chosen.id]! + 1;

    final String styleName = _styleName(style);
    out.add(PlacementDecision(
      studentId: student.id,
      classId: chosen.id,
      rationale: styleMatched
          ? 'Dominant style $styleName matches ${chosen.name}\'s target '
              'style; it had the most room among matching classes.'
          : 'No class targets $styleName; placed in ${chosen.name} as the '
              'class with the most room.',
    ));
  }

  return out;
}

String _styleName(String letter) {
  switch (letter) {
    case 'V':
      return 'Visual';
    case 'A':
      return 'Auditory';
    case 'R':
      return 'Read/Write';
    case 'K':
      return 'Kinaesthetic';
    default:
      return letter;
  }
}
