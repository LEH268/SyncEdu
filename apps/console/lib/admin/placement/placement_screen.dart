import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

import 'placement_repository.dart';

/// The admin placement preview: one row per unplaced student with the class
/// the engine chose, the rationale, and approve / override / skip. The
/// administrator's decision is final.
class PlacementScreen extends StatefulWidget {
  const PlacementScreen({
    super.key,
    required this.repository,
    required this.schoolId,
  });

  final PlacementRepository repository;
  final String schoolId;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  late final Future<_Preview> _preview = _load();
  final Map<String, String> _override = <String, String>{};
  final Set<String> _done = <String>{};

  Future<_Preview> _load() async {
    final List<PlacementDecision> suggestions =
        await widget.repository.compute(widget.schoolId);
    final List<UnplacedStudent> students =
        await widget.repository.unplaced(widget.schoolId);
    final List<ClassOption> classes =
        await widget.repository.classOptions(widget.schoolId);
    final ({Map<String, String> rationales, String source}) prose =
        await widget.repository.rationalesFor(
      schoolId: widget.schoolId,
      suggestions: suggestions,
    );
    return _Preview(suggestions, students, classes, prose.rationales, prose.source);
  }

  Future<void> _approve(
      _Preview preview, PlacementDecision suggestion) async {
    final String? classId = _override[suggestion.studentId] ?? suggestion.classId;
    if (classId == null) return;
    await widget.repository.approve(
      schoolId: widget.schoolId,
      studentId: suggestion.studentId,
      classId: classId,
      rationale: preview.rationales[suggestion.studentId] ?? suggestion.rationale,
      status: _override.containsKey(suggestion.studentId)
          ? 'overridden'
          : 'approved',
    );
    setState(() => _done.add(suggestion.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placement preview')),
      body: FutureBuilder<_Preview>(
        future: _preview,
        builder: (BuildContext context, AsyncSnapshot<_Preview> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final _Preview preview = snapshot.data!;
          final List<PlacementDecision> pending = preview.suggestions
              .where((PlacementDecision s) => !_done.contains(s.studentId))
              .toList();
          if (pending.isEmpty) {
            return const Center(child: Text('Every student has been placed.'));
          }
          final Map<String, String> nameById = <String, String>{
            for (final UnplacedStudent s in preview.students) s.studentId: s.name,
          };

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Chip(
                      label: Text(preview.rationaleSource == 'ai'
                          ? 'Rationales written by AI'
                          : 'Rationales from the placement rule'),
                    ),
                    const Spacer(),
                    FilledButton(
                      key: const Key('placement-approve-all'),
                      onPressed: () async {
                        for (final PlacementDecision s in pending) {
                          if ((_override[s.studentId] ?? s.classId) != null) {
                            await _approve(preview, s);
                          }
                        }
                      },
                      child: const Text('Approve all suggested'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    for (final PlacementDecision s in pending)
                      Card(
                        key: Key('placement-row-${s.studentId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(nameById[s.studentId] ?? s.studentId,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(preview.rationales[s.studentId] ?? s.rationale),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: DropdownButton<String?>(
                                      key: Key('placement-class-${s.studentId}'),
                                      isExpanded: true,
                                      value: _override[s.studentId] ?? s.classId,
                                      hint: const Text('Unassigned'),
                                      items: <DropdownMenuItem<String?>>[
                                        const DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text('Leave unassigned'),
                                        ),
                                        for (final ClassOption c in preview.classes)
                                          DropdownMenuItem<String?>(
                                            value: c.id,
                                            child: Text(
                                                '${c.name} (target ${c.targetStyle.isEmpty ? "—" : c.targetStyle})'),
                                          ),
                                      ],
                                      onChanged: (String? value) => setState(() {
                                        if (value == null) {
                                          _override.remove(s.studentId);
                                        } else {
                                          _override[s.studentId] = value;
                                        }
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    key: Key('placement-approve-${s.studentId}'),
                                    onPressed: (_override[s.studentId] ??
                                                s.classId) ==
                                            null
                                        ? null
                                        : () => _approve(preview, s),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Preview {
  const _Preview(
    this.suggestions,
    this.students,
    this.classes,
    this.rationales,
    this.rationaleSource,
  );

  final List<PlacementDecision> suggestions;
  final List<UnplacedStudent> students;
  final List<ClassOption> classes;
  final Map<String, String> rationales;
  final String rationaleSource;
}
