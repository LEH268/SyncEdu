import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Fixed special-needs vocabulary. Not specified verbatim in the design
/// spec, so this is a judgment call: a small, commonly-used set, with an
/// "Other" free-text entry beside it for anything not covered.
const List<String> kSpecialNeedsVocabulary = <String>[
  'dyslexia',
  'adhd',
  'visual_impairment',
  'hearing_impairment',
  'autism_spectrum',
];

/// Lets an administrator edit one student's special-needs labels: a
/// checklist drawn from [kSpecialNeedsVocabulary], plus free text for
/// anything else. Saving queues a tier-3 delta on `students.special_needs`
/// carrying the value this device last observed -- read fresh from the
/// local row, never assumed -- so a stale write is rejected rather than
/// silently overwriting a concurrent change.
class SpecialNeedsEditor extends StatefulWidget {
  const SpecialNeedsEditor({
    super.key,
    required this.repository,
    required this.studentId,
  });

  final ManagementRepository repository;
  final String studentId;

  @override
  State<SpecialNeedsEditor> createState() => _SpecialNeedsEditorState();
}

class _SpecialNeedsEditorState extends State<SpecialNeedsEditor> {
  final Set<String> _selected = <String>{};
  final TextEditingController _other = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  void _seedFrom(Student student) {
    if (_loaded) return;
    _loaded = true;
    final List<dynamic> raw =
        jsonDecode(student.specialNeeds) as List<dynamic>;
    for (final dynamic value in raw) {
      final String label = value as String;
      if (kSpecialNeedsVocabulary.contains(label)) {
        _selected.add(label);
      } else {
        _other.text = _other.text.isEmpty ? label : '${_other.text}, $label';
      }
    }
  }

  Future<void> _save() async {
    final List<String> newValue = <String>[..._selected];
    final String otherText = _other.text.trim();
    if (otherText.isNotEmpty) {
      newValue.addAll(
        otherText.split(',').map((String s) => s.trim()).where((String s) => s.isNotEmpty),
      );
    }

    await widget.repository.updateStudentSpecialNeeds(
      studentId: widget.studentId,
      newSpecialNeeds: newValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Student?>(
      stream: widget.repository.watchStudent(widget.studentId),
      builder: (BuildContext context, AsyncSnapshot<Student?> snapshot) {
        final Student? student = snapshot.data;
        if (student != null) _seedFrom(student);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ...kSpecialNeedsVocabulary.map(
              (String label) => CheckboxListTile(
                key: Key('need-$label'),
                title: Text(label),
                value: _selected.contains(label),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked ?? false) {
                      _selected.add(label);
                    } else {
                      _selected.remove(label);
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                key: const Key('need-other-text'),
                controller: _other,
                decoration: const InputDecoration(
                  labelText: 'Other (comma-separated free text)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                key: const Key('special-needs-save'),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Lets an administrator move a student to a different class. Tier-3, same
/// as above: the delta carries the class this device last saw the student
/// in.
class StudentClassAssignment extends StatefulWidget {
  const StudentClassAssignment({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.studentId,
  });

  final ManagementRepository repository;
  final String schoolId;
  final String studentId;

  @override
  State<StudentClassAssignment> createState() => _StudentClassAssignmentState();
}

class _StudentClassAssignmentState extends State<StudentClassAssignment> {
  String? _selectedClassId;

  Future<void> _move() async {
    final String? classId = _selectedClassId;
    if (classId == null) return;
    await widget.repository.moveStudentToClass(
      studentId: widget.studentId,
      newClassId: classId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        StreamBuilder<List<ClassesData>>(
          stream: widget.repository.watchClasses(widget.schoolId),
          builder: (BuildContext context, AsyncSnapshot<List<ClassesData>> snapshot) {
            final List<ClassesData> classes = snapshot.data ?? const <ClassesData>[];
            return DropdownButton<String>(
              key: const Key('move-student-class'),
              value: _selectedClassId,
              hint: const Text('Move to class'),
              items: classes
                  .map((ClassesData c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (String? value) => setState(() => _selectedClassId = value),
            );
          },
        ),
        ElevatedButton(
          key: const Key('move-student-submit'),
          onPressed: _move,
          child: const Text('Move'),
        ),
      ],
    );
  }
}
