import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Copies text to the clipboard. Injectable so a widget test can record what
/// was copied instead of driving the real platform clipboard channel, which
/// does not exist inside a widget test.
typedef CopyToClipboard = Future<void> Function(String text);

Future<void> defaultCopyToClipboard(String text) =>
    Clipboard.setData(ClipboardData(text: text));

/// Lets an administrator create a teacher (queuing account creation, which
/// needs the network by nature) and assign an existing teacher to a class
/// and subject.
///
/// Creating a teacher never calls the network from here: it queues a
/// `provision-users` [PendingIntents] row and returns immediately, online or
/// off. There is no sync engine yet in this codebase to drain that row and
/// hand back a real temporary password (see `packages/syncedu_local/lib/src/
/// sync/`), so [provisioningResult] is the seam standing in for that future
/// wiring: a caller (eventually, a widget watching the resolved intent) can
/// pass the password once it exists, and this widget's job -- shown here in
/// isolation -- is only to display it once and offer a copy action.
class TeacherEditor extends StatefulWidget {
  const TeacherEditor({
    super.key,
    required this.repository,
    required this.schoolId,
    this.provisioningResult,
    this.copyToClipboard = defaultCopyToClipboard,
  });

  final ManagementRepository repository;
  final String schoolId;

  /// A temporary password to show once, as if a queued provisioning intent
  /// had just been resolved by the sync engine.
  final String? provisioningResult;

  final CopyToClipboard copyToClipboard;

  @override
  State<TeacherEditor> createState() => _TeacherEditorState();
}

class _TeacherEditorState extends State<TeacherEditor> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _classId = TextEditingController();
  final TextEditingController _subjectId = TextEditingController();
  String? _selectedTeacherId;
  String? _queuedMessage;
  bool _passwordDismissed = false;

  @override
  void dispose() {
    _email.dispose();
    _fullName.dispose();
    _classId.dispose();
    _subjectId.dispose();
    super.dispose();
  }

  Future<void> _createTeacher() async {
    if (_email.text.trim().isEmpty || _fullName.text.trim().isEmpty) return;

    await widget.repository.queueTeacherProvisioning(
      schoolId: widget.schoolId,
      email: _email.text.trim(),
      fullName: _fullName.text.trim(),
    );

    setState(() {
      _queuedMessage = 'Provisioning intent queued for ${_email.text.trim()}';
    });
    _email.clear();
    _fullName.clear();
  }

  Future<void> _assign() async {
    if (_selectedTeacherId == null ||
        _classId.text.trim().isEmpty ||
        _subjectId.text.trim().isEmpty) {
      return;
    }

    await widget.repository.assignTeacherToClass(
      schoolId: widget.schoolId,
      classId: _classId.text.trim(),
      subjectId: _subjectId.text.trim(),
      teacherId: _selectedTeacherId!,
    );
  }

  Future<void> _copyPassword() async {
    final String? password = widget.provisioningResult;
    if (password == null) return;
    await widget.copyToClipboard(password);
    setState(() => _passwordDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    final bool showPassword =
        widget.provisioningResult != null && !_passwordDismissed;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showPassword)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.provisioningResult!,
                      key: const Key('teacher-password-text'),
                    ),
                  ),
                  IconButton(
                    key: const Key('teacher-password-copy'),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy temporary password',
                    onPressed: _copyPassword,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              key: const Key('teacher-email'),
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              key: const Key('teacher-name'),
              controller: _fullName,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              key: const Key('teacher-create'),
              onPressed: _createTeacher,
              child: const Text('Create teacher'),
            ),
          ),
          if (_queuedMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _queuedMessage!,
                key: const Key('teacher-queued-message'),
              ),
            ),
          const Divider(),
          StreamBuilder<List<Profile>>(
            stream: widget.repository.watchTeachers(widget.schoolId),
            builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
              final List<Profile> teachers = snapshot.data ?? const <Profile>[];
              return DropdownButton<String>(
                key: const Key('assign-teacher'),
                value: _selectedTeacherId,
                hint: const Text('Select teacher'),
                items: teachers
                    .map((Profile p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.fullName),
                        ))
                    .toList(),
                onChanged: (String? value) =>
                    setState(() => _selectedTeacherId = value),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              key: const Key('assign-class-id'),
              controller: _classId,
              decoration: const InputDecoration(labelText: 'Class id'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              key: const Key('assign-subject-id'),
              controller: _subjectId,
              decoration: const InputDecoration(labelText: 'Subject id'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              key: const Key('assign-submit'),
              onPressed: _assign,
              child: const Text('Assign to class'),
            ),
          ),
        ],
      ),
    );
  }
}
