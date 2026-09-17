import 'dart:math' as math;
import 'dart:ui';

/// The three node kinds in the class-structure diagram. This is an
/// organisational hierarchy, not a peer sociogram: a student's only edge is to
/// their class, a class's only edge is to its teacher.
enum NodeType { teacher, classNode, student }

/// The two edge kinds. There is deliberately no `studentStudent`: the data
/// holds no peer relationships, and drawing one would be an invention.
enum EdgeType { teacherClass, classStudent }

class DiagramNode {
  const DiagramNode({
    required this.id,
    required this.type,
    required this.label,
    this.parentId,
    this.atRisk = false,
    this.specialNeeds = false,
  });

  final String id;
  final NodeType type;
  final String label;

  /// For a class, the teacher id. For a student, the class id. Null for a
  /// teacher, and null when the parent is outside the visible scope.
  final String? parentId;
  final bool atRisk;
  final bool specialNeeds;
}

class PositionedNode {
  const PositionedNode({required this.node, required this.center, required this.radius});

  final DiagramNode node;
  final Offset center;
  final double radius;

  @override
  bool operator ==(Object other) =>
      other is PositionedNode &&
      other.node.id == node.id &&
      other.center == center &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(node.id, center, radius);
}

class DiagramEdge {
  const DiagramEdge({required this.from, required this.to, required this.type});

  final PositionedNode from;
  final PositionedNode to;
  final EdgeType type;
}

/// The default painted radius of a node. Layout keeps centres at least
/// `2 * kNodeRadius` apart so nodes do not overlap.
const double kNodeRadius = 26;
const double _gap = 14;

/// Lays out [nodes] on [canvas] with a deterministic polar rule — **not** a
/// physics simulation. Identical input gives identical output, every time:
/// teachers ring the centre, each teacher's classes ring the teacher, and
/// each class's students ring the class. Nodes are sorted by id at every
/// level so ordering in the input cannot change positions.
List<PositionedNode> layoutDiagram({
  required List<DiagramNode> nodes,
  required Size canvas,
}) {
  if (nodes.isEmpty) return const <PositionedNode>[];

  final Offset centre = Offset(canvas.width / 2, canvas.height / 2);

  final List<DiagramNode> teachers = _sorted(nodes.where((n) => n.type == NodeType.teacher));
  final Map<String, List<DiagramNode>> classesByTeacher = _childrenByParent(
    nodes.where((n) => n.type == NodeType.classNode),
  );
  final Map<String, List<DiagramNode>> studentsByClass = _childrenByParent(
    nodes.where((n) => n.type == NodeType.student),
  );

  // Orphan classes (teacher not in scope) and orphan students still need a
  // home: gather them under synthetic anchors at the outer edge so nothing is
  // silently dropped.
  final Set<String> teacherIds = teachers.map((t) => t.id).toSet();
  final List<DiagramNode> looseClasses = <DiagramNode>[
    for (final MapEntry<String, List<DiagramNode>> e in classesByTeacher.entries)
      if (!teacherIds.contains(e.key)) ...e.value,
  ];

  final List<PositionedNode> out = <PositionedNode>[];

  // ── teacher ring ────────────────────────────────────────────────────────
  final int teacherSlots = teachers.length + (looseClasses.isEmpty ? 0 : 1);
  final double teacherRing = _ringRadius(teacherSlots, minRadius: 300);
  final Map<String, double> teacherAngle = <String, double>{};

  for (int i = 0; i < teachers.length; i++) {
    final double angle = teacherSlots == 1 ? -math.pi / 2 : (2 * math.pi * i) / teacherSlots - math.pi / 2;
    teacherAngle[teachers[i].id] = angle;
    out.add(PositionedNode(
      node: teachers[i],
      center: _polar(centre, teacherRing, angle),
      radius: kNodeRadius,
    ));
  }

  // ── each teacher's classes ──────────────────────────────────────────────
  for (final DiagramNode teacher in teachers) {
    final List<DiagramNode> classes = _sorted(classesByTeacher[teacher.id] ?? const <DiagramNode>[]);
    final Offset anchor = _polar(centre, teacherRing, teacherAngle[teacher.id]!);
    _placeChildren(
      parentCentre: anchor,
      facing: teacherAngle[teacher.id]!,
      children: classes,
      out: out,
      onPlaced: (DiagramNode klass, Offset at, double facing) {
        final List<DiagramNode> students = _sorted(studentsByClass[klass.id] ?? const <DiagramNode>[]);
        _placeChildren(
          parentCentre: at,
          facing: facing,
          children: students,
          out: out,
        );
      },
    );
  }

  // ── loose classes under a synthetic slot ────────────────────────────────
  if (looseClasses.isNotEmpty) {
    final double angle = teacherSlots == 1
        ? -math.pi / 2
        : (2 * math.pi * teachers.length) / teacherSlots - math.pi / 2;
    final Offset anchor = _polar(centre, teacherRing, angle);
    _placeChildren(
      parentCentre: anchor,
      facing: angle,
      children: _sorted(looseClasses),
      out: out,
      onPlaced: (DiagramNode klass, Offset at, double facing) {
        _placeChildren(
          parentCentre: at,
          facing: facing,
          children: _sorted(studentsByClass[klass.id] ?? const <DiagramNode>[]),
          out: out,
        );
      },
    );
  }

  return <PositionedNode>[
    for (final PositionedNode p in out)
      PositionedNode(
        node: p.node,
        center: Offset(
          p.center.dx.clamp(p.radius, canvas.width - p.radius),
          p.center.dy.clamp(p.radius, canvas.height - p.radius),
        ),
        radius: p.radius,
      ),
  ];
}

/// The class/student edges implied by [positioned]. Teacher→class and
/// class→student only, by construction — there is no path that produces a
/// student→student edge.
List<DiagramEdge> diagramEdges(List<PositionedNode> positioned) {
  final Map<String, PositionedNode> byId = <String, PositionedNode>{
    for (final PositionedNode p in positioned) p.node.id: p,
  };
  final List<DiagramEdge> edges = <DiagramEdge>[];
  for (final PositionedNode p in positioned) {
    final String? parentId = p.node.parentId;
    if (parentId == null) continue;
    final PositionedNode? parent = byId[parentId];
    if (parent == null) continue;
    edges.add(DiagramEdge(
      from: parent,
      to: p,
      type: p.node.type == NodeType.student
          ? EdgeType.classStudent
          : EdgeType.teacherClass,
    ));
  }
  return edges;
}

List<DiagramNode> _sorted(Iterable<DiagramNode> nodes) {
  final List<DiagramNode> list = nodes.toList();
  list.sort((a, b) => a.id.compareTo(b.id));
  return list;
}

Map<String, List<DiagramNode>> _childrenByParent(Iterable<DiagramNode> nodes) {
  final Map<String, List<DiagramNode>> map = <String, List<DiagramNode>>{};
  for (final DiagramNode n in nodes) {
    map.putIfAbsent(n.parentId ?? '', () => <DiagramNode>[]).add(n);
  }
  return map;
}

Offset _polar(Offset origin, double radius, double angle) =>
    Offset(origin.dx + radius * math.cos(angle), origin.dy + radius * math.sin(angle));

/// A ring big enough that [count] nodes sit `2 * kNodeRadius + _gap` apart
/// along its circumference.
double _ringRadius(int count, {required double minRadius}) {
  if (count <= 1) return minRadius;
  final double circumferenceNeeded = count * (2 * kNodeRadius + _gap);
  return math.max(minRadius, circumferenceNeeded / (2 * math.pi));
}

/// Places [children] on a short arc centred on [facing], radiating out from
/// [parentCentre]. A single child sits directly outward; several fan across
/// an arc whose width grows with the count.
void _placeChildren({
  required Offset parentCentre,
  required double facing,
  required List<DiagramNode> children,
  required List<PositionedNode> out,
  void Function(DiagramNode child, Offset at, double facing)? onPlaced,
}) {
  if (children.isEmpty) return;
  final bool toStudents = children.first.type == NodeType.student;
  final double radius = _ringRadius(
    math.max(children.length, 2),
    minRadius: toStudents ? 130 : 210,
  );
  final double arc = math.min(math.pi * 1.2, children.length * 0.55);
  final double start = children.length == 1 ? facing : facing - arc / 2;
  final double step = children.length == 1 ? 0 : arc / (children.length - 1);

  for (int i = 0; i < children.length; i++) {
    final double angle = start + step * i;
    final Offset at = _polar(parentCentre, radius, angle);
    out.add(PositionedNode(node: children[i], center: at, radius: kNodeRadius));
    onPlaced?.call(children[i], at, angle);
  }
}
