import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// One rejected line, kept with the 1-based line number it came from so an
/// administrator can find and fix it in the source file.
class CsvRowError {
  const CsvRowError({required this.lineNumber, required this.message});

  final int lineNumber;
  final String message;
}

/// The outcome of parsing a roster CSV: either every row validated (and
/// [rows] holds them all, ready to preview and submit), or at least one did
/// not, in which case [rows] is ignored entirely -- this task's import is
/// all-or-nothing, so a partially-valid file is never partially imported.
class CsvParseResult {
  const CsvParseResult({required this.rows, required this.errors});

  final List<RosterRow> rows;
  final List<CsvRowError> errors;

  bool get isValid => errors.isEmpty && rows.isNotEmpty;
}

/// Parses a roster CSV of the form `email,full_name[,role]` (a header row is
/// required, columns may be in any order). This is a hand-rolled, simple
/// comma-split parser, not full RFC-4180 -- it does not support quoted
/// fields containing commas. The brief does not call for that, and adding a
/// dependency for it was judged not worth it for a first version; documented
/// here as a known limitation.
CsvParseResult parseRosterCsv(String content) {
  final List<String> lines = content
      .split('\n')
      .map((String l) => l.trimRight())
      .where((String l) => l.trim().isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    return const CsvParseResult(
      rows: <RosterRow>[],
      errors: <CsvRowError>[CsvRowError(lineNumber: 1, message: 'The file is empty.')],
    );
  }

  final List<String> header =
      lines.first.split(',').map((String h) => h.trim().toLowerCase()).toList();
  final int emailIdx = header.indexOf('email');
  final int nameIdx = header.indexOf('full_name');
  final int roleIdx = header.indexOf('role');

  if (emailIdx == -1 || nameIdx == -1) {
    return const CsvParseResult(
      rows: <RosterRow>[],
      errors: <CsvRowError>[
        CsvRowError(
          lineNumber: 1,
          message: 'The header row must include "email" and "full_name" columns.',
        ),
      ],
    );
  }

  final List<RosterRow> rows = <RosterRow>[];
  final List<CsvRowError> errors = <CsvRowError>[];
  final Map<String, int> seenEmails = <String, int>{};

  for (int i = 1; i < lines.length; i++) {
    final int lineNumber = i + 1;
    final List<String> cells = lines[i].split(',').map((String c) => c.trim()).toList();

    if (cells.length <= emailIdx || cells.length <= nameIdx) {
      errors.add(CsvRowError(
        lineNumber: lineNumber,
        message: 'Line $lineNumber is missing a required column.',
      ));
      continue;
    }

    final String email = cells[emailIdx];
    final String fullName = cells[nameIdx];
    final String role = (roleIdx != -1 && cells.length > roleIdx && cells[roleIdx].isNotEmpty)
        ? cells[roleIdx]
        : 'teacher';

    if (email.isEmpty || !email.contains('@')) {
      errors.add(CsvRowError(
        lineNumber: lineNumber,
        message: 'Line $lineNumber has an invalid email address.',
      ));
      continue;
    }

    if (fullName.isEmpty) {
      errors.add(CsvRowError(
        lineNumber: lineNumber,
        message: 'Line $lineNumber is missing a full name.',
      ));
      continue;
    }

    final String key = email.toLowerCase();
    if (seenEmails.containsKey(key)) {
      errors.add(CsvRowError(
        lineNumber: lineNumber,
        message:
            'Line $lineNumber duplicates the email on line ${seenEmails[key]}.',
      ));
      continue;
    }
    seenEmails[key] = lineNumber;

    rows.add(RosterRow(email: email, fullName: fullName, role: role));
  }

  return CsvParseResult(rows: rows, errors: errors);
}

/// Lets an administrator paste a roster CSV, see every row previewed before
/// committing, and submit it as one `provision-users` intent. Parsing and
/// validation are entirely local; nothing here touches the network, online
/// or off -- the import is always queued and always reported as pending,
/// because account creation needs the network by nature regardless of
/// current connectivity.
class CsvImport extends StatefulWidget {
  const CsvImport({
    super.key,
    required this.repository,
    required this.schoolId,
  });

  final ManagementRepository repository;
  final String schoolId;

  @override
  State<CsvImport> createState() => _CsvImportState();
}

class _CsvImportState extends State<CsvImport> {
  final TextEditingController _csv = TextEditingController();
  CsvParseResult? _result;
  bool _imported = false;

  @override
  void dispose() {
    _csv.dispose();
    super.dispose();
  }

  void _preview() {
    setState(() {
      _result = parseRosterCsv(_csv.text);
      _imported = false;
    });
  }

  Future<void> _import() async {
    final CsvParseResult? result = _result;
    if (result == null || !result.isValid) return;

    await widget.repository.queueRosterImport(
      schoolId: widget.schoolId,
      rows: result.rows,
    );

    setState(() => _imported = true);
  }

  @override
  Widget build(BuildContext context) {
    final CsvParseResult? result = _result;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              key: const Key('csv-input'),
              controller: _csv,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Paste roster CSV (email,full_name[,role])',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              key: const Key('csv-preview'),
              onPressed: _preview,
              child: const Text('Preview'),
            ),
          ),
          if (result != null) ...<Widget>[
            if (result.errors.isNotEmpty)
              ...result.errors.map(
                (CsvRowError e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    e.message,
                    key: Key('csv-error-${e.lineNumber}'),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              )
            else
              ...result.rows.map(
                (RosterRow r) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    '${r.email} — ${r.fullName} (${r.role})',
                    key: Key('csv-preview-row-${r.email}'),
                  ),
                ),
              ),
            if (result.isValid)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  key: const Key('csv-import'),
                  onPressed: _import,
                  child: const Text('Import'),
                ),
              ),
            if (_imported)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Import queued — pending until the device reconnects.',
                  key: const Key('csv-import-status'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
