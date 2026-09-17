import 'package:flutter/material.dart';

import 'edge_painter.dart';
import 'layout.dart';

/// The class-structure diagram. Deliberately titled "class structure", not
/// "network" or "relationships": this is an organisational hierarchy, and a
/// reader who takes it for a sociogram will ask a question the data cannot
/// answer.
///
/// Nodes are ordinary positioned widgets inside an [InteractiveViewer]; edges
/// are custom-painted beneath them. The layout is polar and deterministic
/// ([layoutDiagram]).
class RelationshipDiagram extends StatelessWidget {
  const RelationshipDiagram({
    super.key,
    required this.nodes,
    this.canvas = const Size(1600, 1600),
    this.onTapTeacher,
    this.onTapClass,
    this.onTapStudent,
  });

  final List<DiagramNode> nodes;
  final Size canvas;
  final void Function(String teacherId)? onTapTeacher;
  final void Function(String classId)? onTapClass;
  final void Function(String studentId)? onTapStudent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<PositionedNode> placed = layoutDiagram(nodes: nodes, canvas: canvas);
    final List<DiagramEdge> edges = diagramEdges(placed);

    if (placed.isEmpty) {
      return const Center(child: Text('Nothing to show for this scope yet.'));
    }

    return Semantics(
      label: 'Class structure diagram',
      child: InteractiveViewer(
        constrained: false,
        minScale: 0.2,
        maxScale: 3,
        boundaryMargin: const EdgeInsets.all(200),
        child: SizedBox(
          width: canvas.width,
          height: canvas.height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: EdgePainter(
                    edges: edges,
                    glowColor: scheme.primary.withValues(alpha: 0.18),
                    lineColor: scheme.outline,
                  ),
                ),
              ),
              for (final PositionedNode p in placed)
                Positioned(
                  left: p.center.dx - p.radius,
                  top: p.center.dy - p.radius,
                  width: p.radius * 2,
                  height: p.radius * 2,
                  child: _NodeChip(
                    node: p.node,
                    onTap: switch (p.node.type) {
                      NodeType.teacher => onTapTeacher == null
                          ? null
                          : () => onTapTeacher!(p.node.id),
                      NodeType.classNode => onTapClass == null
                          ? null
                          : () => onTapClass!(p.node.id),
                      NodeType.student => onTapStudent == null
                          ? null
                          : () => onTapStudent!(p.node.id),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeChip extends StatelessWidget {
  const _NodeChip({required this.node, this.onTap});

  final DiagramNode node;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fill = switch (node.type) {
      NodeType.teacher => scheme.primaryContainer,
      NodeType.classNode => scheme.secondaryContainer,
      NodeType.student => scheme.surfaceContainerHighest,
    };

    return Tooltip(
      message: node.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: node.atRisk ? scheme.error : scheme.outlineVariant,
              width: node.atRisk ? 3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  _initials(node.label),
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.clip,
                ),
              ),
              if (node.specialNeeds)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.star, size: 12, color: scheme.tertiary,
                      key: const Key('special-needs-flag')),
                ),
              if (node.atRisk)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.warning, size: 12, color: scheme.error,
                      key: const Key('at-risk-flag')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String label) {
    final List<String> parts = label.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1).toString() +
            parts.last.characters.take(1).toString())
        .toUpperCase();
  }
}
