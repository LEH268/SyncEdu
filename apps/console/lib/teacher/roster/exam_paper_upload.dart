import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'exam_paper_repository.dart';

class PickedExamFile {
  const PickedExamFile({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}

typedef ExamFilePicker = Future<PickedExamFile?> Function();

Future<PickedExamFile?> defaultExamFilePicker() async {
  const XTypeGroup group = XTypeGroup(
    label: 'exam paper',
    extensions: <String>['pdf', 'png', 'jpg', 'jpeg'],
  );
  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[group]);
  if (file == null) return null;
  return PickedExamFile(name: file.name, bytes: await file.readAsBytes());
}

/// Lets a teacher upload one student's marked paper for a chapter. The gaps
/// the analysis finds land in the same weakness store as quiz results, with
/// `source = 'exam'`, so they surface in the student's struggle tags and the
/// class heatmap.
class ExamPaperUpload extends StatefulWidget {
  const ExamPaperUpload({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.studentId,
    required this.chapters,
    this.filePicker = defaultExamFilePicker,
  });

  final ExamPaperRepository repository;
  final String schoolId;
  final String studentId;

  /// (chapterId, title) pairs for the subjects this student takes.
  final List<(String, String)> chapters;
  final ExamFilePicker filePicker;

  @override
  State<ExamPaperUpload> createState() => _ExamPaperUploadState();
}

class _ExamPaperUploadState extends State<ExamPaperUpload> {
  String? _chapterId;
  String? _error;
  bool _busy = false;

  Future<void> _pickAndUpload() async {
    final String? chapterId = _chapterId;
    if (chapterId == null) return;
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final PickedExamFile? picked = await widget.filePicker();
      if (picked == null) return;
      await widget.repository.upload(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        chapterId: chapterId,
        fileName: picked.name,
        bytes: picked.bytes,
      );
    } on ExamPaperOffline catch (e) {
      setState(() => _error = e.toString());
    } catch (e) {
      setState(() => _error = 'Upload failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButton<String>(
          key: const Key('exam-chapter'),
          value: _chapterId,
          hint: const Text('Chapter this paper covers'),
          isExpanded: true,
          items: <DropdownMenuItem<String>>[
            for (final (String, String) c in widget.chapters)
              DropdownMenuItem<String>(value: c.$1, child: Text(c.$2)),
          ],
          onChanged: (String? v) => setState(() => _chapterId = v),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('exam-pick'),
          onPressed: _chapterId == null || _busy ? null : _pickAndUpload,
          child: Text(_busy ? 'Uploading…' : 'Upload marked paper'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!,
                key: const Key('exam-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 12),
        StreamBuilder<List<ExamPaperRecord>>(
          stream: widget.repository.watchFor(widget.studentId),
          builder: (BuildContext context,
              AsyncSnapshot<List<ExamPaperRecord>> snapshot) {
            final List<ExamPaperRecord> papers =
                snapshot.data ?? const <ExamPaperRecord>[];
            return Column(
              children: <Widget>[
                for (final ExamPaperRecord p in papers)
                  ListTile(
                    key: Key('exam-paper-${p.id}'),
                    title: Text(p.analysisStatus),
                    subtitle: p.note == null ? null : Text(p.note!),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
