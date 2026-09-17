import 'package:drift/drift.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'layout.dart';

/// Builds the class-structure node list from the local mirror, scoped to what
/// the viewer may see: a teacher sees only the classes they teach; an admin
/// sees every teacher and class in the school. No student-to-student edges
/// exist because the data holds no peer relationships.
class DiagramRepository {
  DiagramRepository(this._db);

  final SyncEduDatabase _db;

  /// [teacherId] non-null restricts to that teacher's classes (the teacher
  /// console). Null returns the whole school (the admin console).
  Future<List<DiagramNode>> nodes({
    required String schoolId,
    String? teacherId,
  }) async {
    final List<Profile> teachers = await (_db.select(_db.profiles)
          ..where(($ProfilesTable t) =>
              t.schoolId.equals(schoolId) &
              t.role.equals('teacher') &
              t.deletedAt.isNull()))
        .get();
    final List<ClassSubject> links = await (_db.select(_db.classSubjects)
          ..where(($ClassSubjectsTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .get();
    final List<ClassesData> classes = await (_db.select(_db.classes)
          ..where(($ClassesTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .get();
    final List<Student> students = await (_db.select(_db.students)
          ..where(($StudentsTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull()))
        .get();

    // class id -> the teacher who teaches it (first link wins; the diagram is
    // a hierarchy, not a many-to-many map).
    final Map<String, String> teacherOfClass = <String, String>{};
    for (final ClassSubject link in links) {
      teacherOfClass.putIfAbsent(link.classId, () => link.teacherId);
    }

    final Set<String> visibleTeachers = teacherId == null
        ? teachers.map((Profile t) => t.id).toSet()
        : <String>{teacherId};
    final Set<String> visibleClasses = <String>{
      for (final ClassesData c in classes)
        if (teacherId == null || teacherOfClass[c.id] == teacherId) c.id,
    };

    final Set<String> atRiskStudents = await _atRiskStudentIds(schoolId);

    final List<DiagramNode> out = <DiagramNode>[];
    for (final Profile t in teachers) {
      if (!visibleTeachers.contains(t.id)) continue;
      out.add(DiagramNode(id: t.id, type: NodeType.teacher, label: t.fullName));
    }
    for (final ClassesData c in classes) {
      if (!visibleClasses.contains(c.id)) continue;
      out.add(DiagramNode(
        id: c.id,
        type: NodeType.classNode,
        label: c.name,
        parentId: teacherOfClass[c.id],
      ));
    }
    for (final Student s in students) {
      if (s.classId == null || !visibleClasses.contains(s.classId)) continue;
      final Profile? profile = await (_db.select(_db.profiles)
            ..where(($ProfilesTable p) => p.id.equals(s.profileId)))
          .getSingleOrNull();
      out.add(DiagramNode(
        id: s.id,
        type: NodeType.student,
        label: profile?.fullName ?? 'Student',
        parentId: s.classId,
        atRisk: atRiskStudents.contains(s.id),
        specialNeeds: s.specialNeeds.trim().isNotEmpty &&
            s.specialNeeds.trim() != '[]',
      ));
    }
    return out;
  }

  /// A light at-risk signal for the diagram flag: a student with any weakness
  /// row at or above 0.5. The console's own at-risk table is the authority;
  /// this is only a visual cue.
  Future<Set<String>> _atRiskStudentIds(String schoolId) async {
    final List<WeaknessesData> rows = await (_db.select(_db.weaknesses)
          ..where(($WeaknessesTable t) =>
              t.schoolId.equals(schoolId) &
              t.deletedAt.isNull() &
              t.weight.isBiggerOrEqualValue(0.5)))
        .get();
    return rows.map((WeaknessesData w) => w.studentId).toSet();
  }
}
