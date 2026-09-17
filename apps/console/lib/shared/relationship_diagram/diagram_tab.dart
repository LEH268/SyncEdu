import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'diagram_repository.dart';
import 'diagram_view.dart';
import 'layout.dart';

/// Hosts the [RelationshipDiagram] for one role. The copy says "class
/// structure", never "network" — this is an organisational hierarchy.
class RelationshipDiagramTab extends StatefulWidget {
  const RelationshipDiagramTab({
    super.key,
    required this.db,
    required this.schoolId,
    this.teacherId,
  });

  final SyncEduDatabase db;
  final String schoolId;

  /// Non-null on the teacher console: the diagram is limited to their classes.
  final String? teacherId;

  @override
  State<RelationshipDiagramTab> createState() => _RelationshipDiagramTabState();
}

class _RelationshipDiagramTabState extends State<RelationshipDiagramTab> {
  late Future<List<DiagramNode>> _nodes = DiagramRepository(widget.db)
      .nodes(schoolId: widget.schoolId, teacherId: widget.teacherId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class structure'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _nodes = DiagramRepository(widget.db).nodes(
                schoolId: widget.schoolId,
                teacherId: widget.teacherId,
              );
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<DiagramNode>>(
        future: _nodes,
        builder:
            (BuildContext context, AsyncSnapshot<List<DiagramNode>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return RelationshipDiagram(
            nodes: snapshot.data ?? const <DiagramNode>[],
            onTapStudent: (String id) =>
                context.go('/${widget.teacherId == null ? 'admin' : 'teacher'}'
                    '/roster/students/$id'),
          );
        },
      ),
    );
  }
}
