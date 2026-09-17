import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Lets a teacher read and add observations about a student.
///
/// Writes go through [ObservationRepository.addObservation], which queues a
/// tier-1 append-only insert -- never an update -- so two teachers writing
/// about the same student at the same time both survive as independent rows.
/// The local row (and therefore this widget's list) updates immediately on
/// write; nothing here waits on a network round trip.
class ObservationEditor extends StatefulWidget {
  const ObservationEditor({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.studentId,
    required this.teacherId,
  });

  final ObservationRepository repository;
  final String schoolId;
  final String studentId;
  final String teacherId;

  @override
  State<ObservationEditor> createState() => _ObservationEditorState();
}

class _ObservationEditorState extends State<ObservationEditor> {
  final TextEditingController _bodyController = TextEditingController();

  /// Formats [at] without pulling in `intl` for a single date string --
  /// e.g. "2026-09-06 14:05".
  static String _formatDate(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${at.year}-${two(at.month)}-${two(at.day)} '
        '${two(at.hour)}:${two(at.minute)}';
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String body = _bodyController.text.trim();
    if (body.isEmpty) return;
    await widget.repository.addObservation(
      schoolId: widget.schoolId,
      studentId: widget.studentId,
      teacherId: widget.teacherId,
      body: body,
    );
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const Key('observation-body'),
                  controller: _bodyController,
                  decoration:
                      const InputDecoration(labelText: 'Add an observation'),
                ),
              ),
              IconButton(
                key: const Key('observation-submit'),
                icon: const Icon(Icons.add),
                onPressed: _submit,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ObservationRow>>(
            stream: widget.repository.watchObservations(widget.studentId),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<ObservationRow>> snapshot,
            ) {
              final List<ObservationRow> observations =
                  snapshot.data ?? const <ObservationRow>[];
              if (observations.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No observations recorded yet.'),
                );
              }
              return ListView.builder(
                key: const Key('observation-list'),
                itemCount: observations.length,
                itemBuilder: (BuildContext context, int index) {
                  final ObservationRow observation = observations[index];
                  return ListTile(
                    key: Key('observation-${observation.id}'),
                    title: Text(observation.body),
                    subtitle: Text(
                      '${observation.teacherName} · '
                      '${_formatDate(observation.createdAt.toLocal())}',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
