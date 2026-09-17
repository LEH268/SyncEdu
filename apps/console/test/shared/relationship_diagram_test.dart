

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/shared/relationship_diagram/diagram_view.dart';
import 'package:syncedu_console/shared/relationship_diagram/layout.dart';

const Size _canvas = Size(1600, 1600);

List<DiagramNode> _fixture() => <DiagramNode>[
      const DiagramNode(id: 't1', type: NodeType.teacher, label: 'Teacher One'),
      const DiagramNode(id: 't2', type: NodeType.teacher, label: 'Teacher Two'),
      const DiagramNode(id: 'c1', type: NodeType.classNode, label: '4 Alpha', parentId: 't1'),
      const DiagramNode(id: 'c2', type: NodeType.classNode, label: '4 Beta', parentId: 't1'),
      const DiagramNode(id: 'c3', type: NodeType.classNode, label: '5 Alpha', parentId: 't2'),
      const DiagramNode(id: 's1', type: NodeType.student, label: 'Ali', parentId: 'c1', atRisk: true),
      const DiagramNode(id: 's2', type: NodeType.student, label: 'Bina', parentId: 'c1', specialNeeds: true),
      const DiagramNode(id: 's3', type: NodeType.student, label: 'Chan', parentId: 'c2'),
      const DiagramNode(id: 's4', type: NodeType.student, label: 'Devi', parentId: 'c3'),
    ];

void main() {
  test('the layout is deterministic and polar, not a physics simulation', () {
    expect(
      layoutDiagram(nodes: _fixture(), canvas: _canvas),
      layoutDiagram(nodes: _fixture(), canvas: _canvas),
    );
    // Input order must not matter.
    final List<DiagramNode> shuffled = _fixture().reversed.toList();
    expect(
      layoutDiagram(nodes: shuffled, canvas: _canvas),
      layoutDiagram(nodes: _fixture(), canvas: _canvas),
    );
  });

  test('teachers ring the centre and their classes ring them', () {
    final List<PositionedNode> placed = layoutDiagram(nodes: _fixture(), canvas: _canvas);
    final Offset centre = Offset(_canvas.width / 2, _canvas.height / 2);
    PositionedNode byId(String id) => placed.firstWhere((p) => p.node.id == id);

    final double t1 = (byId('t1').center - centre).distance;
    final double c1FromT1 = (byId('c1').center - byId('t1').center).distance;
    final double s1FromC1 = (byId('s1').center - byId('c1').center).distance;

    // A class sits closer to its own teacher than to the diagram centre.
    expect(c1FromT1, lessThan((byId('c1').center - centre).distance));
    expect(t1, greaterThan(0));
    expect(c1FromT1, greaterThan(0));
    expect(s1FromC1, greaterThan(0));
  });

  test('every node lands inside the canvas', () {
    for (final PositionedNode p in layoutDiagram(nodes: _fixture(), canvas: _canvas)) {
      expect(p.center.dx, inInclusiveRange(p.radius, _canvas.width - p.radius));
      expect(p.center.dy, inInclusiveRange(p.radius, _canvas.height - p.radius));
    }
  });

  test('no two nodes overlap at the default node radius', () {
    final List<PositionedNode> placed = layoutDiagram(nodes: _fixture(), canvas: _canvas);
    for (int i = 0; i < placed.length; i++) {
      for (int j = i + 1; j < placed.length; j++) {
        final double d = (placed[i].center - placed[j].center).distance;
        expect(d, greaterThan(placed[i].radius + placed[j].radius - 0.5),
            reason: '${placed[i].node.id} overlaps ${placed[j].node.id}');
      }
    }
  });

  test('a single teacher with one class still lays out sensibly', () {
    final List<PositionedNode> placed = layoutDiagram(
      nodes: const <DiagramNode>[
        DiagramNode(id: 't1', type: NodeType.teacher, label: 'Solo'),
        DiagramNode(id: 'c1', type: NodeType.classNode, label: 'Only', parentId: 't1'),
        DiagramNode(id: 's1', type: NodeType.student, label: 'One', parentId: 'c1'),
      ],
      canvas: _canvas,
    );
    expect(placed, hasLength(3));
    for (final PositionedNode p in placed) {
      expect(p.center.dx.isFinite && p.center.dy.isFinite, isTrue);
    }
  });

  test('an empty node list yields an empty layout, not an exception', () {
    expect(layoutDiagram(nodes: const <DiagramNode>[], canvas: _canvas), isEmpty);
  });

  test('there are no student-to-student edges', () {
    final List<DiagramEdge> edges =
        diagramEdges(layoutDiagram(nodes: _fixture(), canvas: _canvas));
    expect(edges, isNotEmpty);
    expect(
      edges.any((DiagramEdge e) =>
          e.from.node.type == NodeType.student && e.to.node.type == NodeType.student),
      isFalse,
    );
  });

  testWidgets('tapping a class, teacher and student fire their callbacks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final List<String> tapped = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RelationshipDiagram(
          nodes: _fixture(),
          onTapTeacher: (id) => tapped.add('teacher:$id'),
          onTapClass: (id) => tapped.add('class:$id'),
          onTapStudent: (id) => tapped.add('student:$id'),
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byTooltip('Teacher One'), warnIfMissed: false);
    await tester.tap(find.byTooltip('4 Alpha'), warnIfMissed: false);
    await tester.tap(find.byTooltip('Ali'), warnIfMissed: false);
    await tester.pump();

    expect(tapped, containsAll(<String>['teacher:t1', 'class:c1', 'student:s1']));
  });

  testWidgets('at-risk and special-needs students are visually flagged', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RelationshipDiagram(nodes: _fixture())),
    ));
    await tester.pump();
    expect(find.byKey(const Key('at-risk-flag')), findsWidgets);
    expect(find.byKey(const Key('special-needs-flag')), findsOneWidget);
  });

  testWidgets('an empty scope explains rather than throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RelationshipDiagram(nodes: <DiagramNode>[])),
    ));
    await tester.pump();
    expect(find.textContaining('Nothing to show'), findsOneWidget);
  });
}
