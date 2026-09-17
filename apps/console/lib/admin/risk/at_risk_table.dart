import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// Renders an already-computed at-risk student list with class and
/// risk-level filters that compose.
///
/// This widget never computes risk: every row, level and reason comes
/// straight from the [RiskRow] list it is given. Filtering here is plain
/// UI-level narrowing of the pre-computed rows, not figure computation.
class AtRiskTable extends StatefulWidget {
  const AtRiskTable({super.key, required this.rows});

  final List<RiskRow> rows;

  @override
  State<AtRiskTable> createState() => _AtRiskTableState();
}

class _AtRiskTableState extends State<AtRiskTable> {
  String? _selectedClassId;
  RiskLevel? _selectedRiskLevel;

  List<RiskRow> get _filteredRows {
    return widget.rows.where((RiskRow row) {
      if (_selectedClassId != null && row.classId != _selectedClassId) {
        return false;
      }
      if (_selectedRiskLevel != null && row.level != _selectedRiskLevel) {
        return false;
      }
      return true;
    }).toList();
  }

  static String _levelLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'High';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.none:
        return 'None';
    }
  }

  static Color _levelColor(BuildContext context, RiskLevel level) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (level) {
      case RiskLevel.high:
        return scheme.error;
      case RiskLevel.medium:
        return Colors.amber;
      case RiskLevel.none:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> classes = <String, String>{
      for (final RiskRow row in widget.rows) row.classId: row.className,
    };
    final List<RiskRow> filtered = _filteredRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            DropdownButton<String?>(
              key: const Key('at-risk-class-filter'),
              value: _selectedClassId,
              hint: const Text('All classes'),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All classes'),
                ),
                for (final MapEntry<String, String> entry in classes.entries)
                  DropdownMenuItem<String?>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
              ],
              onChanged: (String? value) =>
                  setState(() => _selectedClassId = value),
            ),
            DropdownButton<RiskLevel?>(
              key: const Key('at-risk-level-filter'),
              value: _selectedRiskLevel,
              hint: const Text('All risk levels'),
              items: <DropdownMenuItem<RiskLevel?>>[
                const DropdownMenuItem<RiskLevel?>(
                  value: null,
                  child: Text('All risk levels'),
                ),
                for (final RiskLevel level in RiskLevel.values)
                  DropdownMenuItem<RiskLevel?>(
                    value: level,
                    child: Text(_levelLabel(level)),
                  ),
              ],
              onChanged: (RiskLevel? value) =>
                  setState(() => _selectedRiskLevel = value),
            ),
            if (_selectedClassId != null || _selectedRiskLevel != null)
              TextButton(
                key: const Key('at-risk-clear-filters'),
                onPressed: () => setState(() {
                  _selectedClassId = null;
                  _selectedRiskLevel = null;
                }),
                child: const Text('Clear filters'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No students match these filters.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (BuildContext context, int index) {
              final RiskRow row = filtered[index];
              return ListTile(
                key: Key('at-risk-row-${row.studentId}'),
                leading: Container(
                  key: Key('at-risk-level-${row.studentId}'),
                  width: 16,
                  height: 16,
                  color: _levelColor(context, row.level),
                ),
                title: Text(row.studentName),
                subtitle: Text(
                  '${row.className} · ${_levelLabel(row.level)} · '
                  '${row.reasons.join('; ')}',
                ),
              );
            },
          ),
      ],
    );
  }
}
