import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/shared/relationship_diagram/diagram_repository.dart';
import 'package:syncedu_console/shared/relationship_diagram/layout.dart';
import 'package:syncedu_local/syncedu_local.dart';

final DateTime _now = DateTime.utc(2026, 1, 1);

Future<void> _seed(SyncEduDatabase db) async {
  for (final String t in <String>['t1', 't2']) {
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: t, schoolId: 's', role: 'teacher', fullName: 'Teacher $t',
          email: '$t@t', createdAt: _now, updatedAt: _now,
        ));
  }
  for (final (String, String) c in <(String, String)>[('c1', 't1'), ('c2', 't2')]) {
    await db.into(db.classes).insert(ClassesCompanion.insert(
          id: c.$1, schoolId: 's', name: 'Class ${c.$1}', yearLevel: 4,
          createdAt: _now, updatedAt: _now,
        ));
    await db.into(db.classSubjects).insert(ClassSubjectsCompanion.insert(
          id: 'cs-${c.$1}', schoolId: 's', classId: c.$1, subjectId: 'sub',
          teacherId: c.$2, createdAt: _now, updatedAt: _now,
        ));
  }
  for (final (String, String) s in <(String, String)>[('s1', 'c1'), ('s2', 'c2')]) {
    await db.into(db.profiles).insert(ProfilesCompanion.insert(
          id: 'p-${s.$1}', schoolId: 's', role: 'student',
          fullName: 'Student ${s.$1}', email: '${s.$1}@t',
          createdAt: _now, updatedAt: _now,
        ));
    await db.into(db.students).insert(StudentsCompanion.insert(
          id: s.$1, schoolId: 's', profileId: 'p-${s.$1}',
          classId: Value(s.$2), createdAt: _now, updatedAt: _now,
        ));
  }
}

void main() {
  late SyncEduDatabase db;
  setUp(() async {
    db = SyncEduDatabase.forTesting();
    await _seed(db);
  });
  tearDown(() => db.close());

  test('an admin sees every teacher and class', () async {
    final List<DiagramNode> nodes =
        await DiagramRepository(db).nodes(schoolId: 's');
    expect(nodes.where((n) => n.type == NodeType.teacher).length, 2);
    expect(nodes.where((n) => n.type == NodeType.classNode).length, 2);
    expect(nodes.where((n) => n.type == NodeType.student).length, 2);
  });

  test('a teacher sees only their own classes and their students', () async {
    final List<DiagramNode> nodes =
        await DiagramRepository(db).nodes(schoolId: 's', teacherId: 't1');
    expect(nodes.where((n) => n.type == NodeType.classNode).single.id, 'c1');
    expect(nodes.where((n) => n.type == NodeType.student).single.id, 's1');
  });

  test('there are no student-to-student edges', () async {
    final List<DiagramNode> nodes =
        await DiagramRepository(db).nodes(schoolId: 's');
    final edges = diagramEdges(
      layoutDiagram(nodes: nodes, canvas: const Size(1600, 1600)),
    );
    expect(
      edges.any((e) =>
          e.from.node.type == NodeType.student &&
          e.to.node.type == NodeType.student),
      isFalse,
    );
  });
}
