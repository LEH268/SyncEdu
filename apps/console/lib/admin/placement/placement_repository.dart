import 'package:drift/drift.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

import '../../functions/console_functions.dart';

/// One unplaced student as the preview table needs them.
class UnplacedStudent {
  const UnplacedStudent({
    required this.studentId,
    required this.name,
    required this.dominantStyle,
  });

  final String studentId;
  final String name;

  /// From `pre_admission_results.dominant_style`, or null if the student has
  /// not sat the instrument — those are left unassigned, never guessed.
  final String? dominantStyle;
}

/// Initial placement, admin-side. The assignment is computed by
/// `suggestPlacements` in syncedu_core (target learning style, never the class
/// name); `suggest-placement` only writes the rationale prose.
class PlacementRepository {
  PlacementRepository({
    required SyncEduDatabase db,
    required this.functions,
  })  : _db = db,
        _management = ManagementRepository(db, OutboxWriter(db)),
        _outbox = OutboxWriter(db);

  final SyncEduDatabase _db;
  final ManagementRepository _management;
  final OutboxWriter _outbox;
  final ConsoleFunctions functions;
  static const Uuid _uuid = Uuid();

  Future<List<UnplacedStudent>> unplaced(String schoolId) async {
    final List<Student> students = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.schoolId.equals(schoolId) &
              t.classId.isNull() &
              t.deletedAt.isNull()))
        .get();

    final List<UnplacedStudent> out = <UnplacedStudent>[];
    for (final Student s in students) {
      final Profile? profile = await (_db.select(_db.profiles)
            ..where(($ProfilesTable p) => p.id.equals(s.profileId)))
          .getSingleOrNull();
      final PreAdmissionResult? pre = await (_db.select(_db.preAdmissionResults)
            ..where(($PreAdmissionResultsTable t) =>
                t.studentId.equals(s.id) & t.deletedAt.isNull()))
          .getSingleOrNull();
      out.add(UnplacedStudent(
        studentId: s.id,
        name: profile?.fullName ?? 'Student',
        dominantStyle: pre?.dominantStyle,
      ));
    }
    return out;
  }

  Future<List<ClassOption>> classOptions(String schoolId) async {
    final List<ClassesData> classes = await (_db.select(_db.classes)
          ..where(($ClassesTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .get();
    final List<Student> students = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .get();
    final Map<String, int> size = <String, int>{};
    for (final Student s in students) {
      if (s.classId != null) {
        size.update(s.classId!, (int n) => n + 1, ifAbsent: () => 1);
      }
    }
    return <ClassOption>[
      for (final ClassesData c in classes)
        ClassOption(
          id: c.id,
          name: c.name,
          targetStyle: c.targetLearningStyle ?? '',
          size: size[c.id] ?? 0,
        ),
    ];
  }

  Future<List<PlacementDecision>> compute(String schoolId) async {
    final List<UnplacedStudent> students = await unplaced(schoolId);
    final List<ClassOption> classes = await classOptions(schoolId);
    return suggestPlacements(
      students: <StudentProfile>[
        for (final UnplacedStudent s in students)
          StudentProfile(id: s.studentId, dominant: s.dominantStyle),
      ],
      classes: classes,
    );
  }

  /// Asks `suggest-placement` for prose rationales. Returns a map keyed by
  /// student id, plus whether the model or the rule wrote them. Falls back to
  /// the engine's own rationale string on any failure.
  Future<({Map<String, String> rationales, String source})> rationalesFor({
    required String schoolId,
    required List<PlacementDecision> suggestions,
  }) async {
    final Map<String, String> fallback = <String, String>{
      for (final PlacementDecision s in suggestions) s.studentId: s.rationale,
    };
    if (!functions.online) {
      return (rationales: fallback, source: 'rule');
    }

    final List<UnplacedStudent> students = await unplaced(schoolId);
    final Map<String, UnplacedStudent> byId = <String, UnplacedStudent>{
      for (final UnplacedStudent s in students) s.studentId: s,
    };
    final List<ClassOption> classes = await classOptions(schoolId);
    final Map<String, ClassOption> classById = <String, ClassOption>{
      for (final ClassOption c in classes) c.id: c,
    };

    try {
      final Map<String, dynamic> result = await functions.suggestPlacement(
        <String, dynamic>{
          'suggestions': <Map<String, dynamic>>[
            for (final PlacementDecision s in suggestions)
              <String, dynamic>{
                'studentId': s.studentId,
                'studentName': byId[s.studentId]?.name ?? 'the student',
                'dominantStyle': byId[s.studentId]?.dominantStyle,
                'suggestedClassId': s.classId,
                'suggestedClassName': classById[s.classId]?.name,
                'suggestedClassTargetStyle': classById[s.classId]?.targetStyle,
                'fallbackRationale': s.rationale,
              },
          ],
        },
      );
      final Map<String, String> out = Map<String, String>.from(fallback);
      for (final dynamic row
          in (result['suggestions'] as List<dynamic>? ?? <dynamic>[])) {
        final Map<String, dynamic> m =
            (row as Map<dynamic, dynamic>).cast<String, dynamic>();
        out[m['studentId'] as String] = m['rationale'] as String;
      }
      return (rationales: out, source: result['source'] as String? ?? 'ai');
    } catch (_) {
      return (rationales: fallback, source: 'rule');
    }
  }

  /// Applies one placement: the class change is a tier-3 delta on
  /// `students.class_id`; the record is a tier-1 `placement_suggestions` row.
  Future<void> approve({
    required String schoolId,
    required String studentId,
    required String classId,
    required String rationale,
    String status = 'approved',
  }) async {
    await _management.moveStudentToClass(studentId: studentId, newClassId: classId);

    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    await _db.into(_db.placementSuggestions).insert(
          PlacementSuggestionsCompanion.insert(
            id: id,
            schoolId: schoolId,
            studentId: studentId,
            suggestedClassId: Value(classId),
            rationale: Value(rationale),
            status: Value(status),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(
      table: 'placement_suggestions',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'suggested_class_id': classId,
        'rationale': rationale,
        'status': status,
      },
    );
  }
}
