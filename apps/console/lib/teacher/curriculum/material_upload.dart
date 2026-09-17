import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// A file picked for upload, decoupled from `file_selector`'s own type so a
/// widget test can hand [MaterialUpload] a result directly without driving a
/// real OS file dialog (which does not exist inside a widget test).
class PickedMaterialFile {
  const PickedMaterialFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

typedef MaterialFilePicker = Future<PickedMaterialFile?> Function();

/// The production picker: opens the OS file dialog restricted to the formats
/// [CurriculumRepository.queueMaterialUpload] accepts.
Future<PickedMaterialFile?> defaultMaterialFilePicker() async {
  final XTypeGroup typeGroup = XTypeGroup(
    label: 'materials',
    extensions: const <String>['pdf', 'png', 'jpg', 'jpeg'],
  );
  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (file == null) return null;
  final Uint8List bytes = await file.readAsBytes();
  return PickedMaterialFile(name: file.name, bytes: bytes);
}

/// Lets a teacher queue a material for a chapter and see, per material,
/// where it stands in the `pending -> pack_ready -> pool_ready -> ready`
/// ingestion walk. Picking a file never blocks on the network: the row is
/// queued locally and shown immediately.
class MaterialUpload extends StatefulWidget {
  const MaterialUpload({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.chapterId,
    this.filePicker = defaultMaterialFilePicker,
  });

  final CurriculumRepository repository;
  final String schoolId;
  final String chapterId;
  final MaterialFilePicker filePicker;

  @override
  State<MaterialUpload> createState() => _MaterialUploadState();
}

class _MaterialUploadState extends State<MaterialUpload> {
  String? _error;

  Future<void> _pickAndQueue() async {
    setState(() => _error = null);
    final PickedMaterialFile? picked = await widget.filePicker();
    if (picked == null) return;

    try {
      await widget.repository.queueMaterialUpload(
        schoolId: widget.schoolId,
        chapterId: widget.chapterId,
        fileName: picked.name,
        bytes: picked.bytes,
      );
    } on MaterialRejected catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            key: const Key('material-pick'),
            onPressed: _pickAndQueue,
            child: const Text('Choose file'),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _error!,
              key: const Key('material-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: StreamBuilder<List<MaterialRecord>>(
            stream: widget.repository.watchMaterialsFor(widget.chapterId),
            builder:
                (BuildContext context, AsyncSnapshot<List<MaterialRecord>> snapshot) {
              final List<MaterialRecord> materials =
                  snapshot.data ?? const <MaterialRecord>[];
              return ListView.builder(
                key: const Key('material-list'),
                itemCount: materials.length,
                itemBuilder: (BuildContext context, int index) {
                  final MaterialRecord material = materials[index];
                  return ListTile(
                    key: Key('material-${material.id}'),
                    title: Text(material.mime),
                    subtitle: Text(
                      material.ingestionStatus,
                      key: Key('material-status-${material.id}'),
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
