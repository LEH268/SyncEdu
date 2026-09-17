import 'package:flutter/material.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// One row of a class roster: a student's identity, their declared special
/// needs, and their risk status.
///
/// [riskLevel] is nullable rather than defaulting to [RiskLevel.none],
/// because [atRiskStudents] omits a student entirely when no rule fires --
/// null here means "not present in that list", matching that contract
/// directly rather than inventing a third state.
class RosterEntry {
  const RosterEntry({
    required this.studentId,
    required this.studentName,
    this.specialNeeds = const <String>[],
    this.riskLevel,
    this.riskReasons = const <String>[],
  });

  final String studentId;
  final String studentName;
  final List<String> specialNeeds;
  final RiskLevel? riskLevel;
  final List<String> riskReasons;
}

/// Renders an already-assembled class roster.
///
/// This widget never computes risk or reads special-needs data itself: every
/// [RosterEntry] is handed in already resolved, so the roster renders the
/// same figures every other screen in this phase does.
class ClassRoster extends StatelessWidget {
  const ClassRoster({super.key, required this.entries, this.onStudentTap});

  final List<RosterEntry> entries;
  final ValueChanged<RosterEntry>? onStudentTap;

  static Color _riskColor(BuildContext context, RiskLevel level) {
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

  static String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return 'At risk (high)';
      case RiskLevel.medium:
        return 'At risk (medium)';
      case RiskLevel.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No students in this class yet.'),
      );
    }

    return ListView.builder(
      key: const Key('class-roster'),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final RosterEntry entry = entries[index];
        final RiskLevel? level = entry.riskLevel;
        return ListTile(
          key: Key('roster-${entry.studentId}'),
          title: Text(entry.studentName),
          subtitle: entry.specialNeeds.isEmpty
              ? null
              : Text(entry.specialNeeds.join(', ')),
          trailing: level == null || level == RiskLevel.none
              ? null
              : Tooltip(
                  message: entry.riskReasons.join('; '),
                  child: Chip(
                    key: Key('risk-${entry.studentId}'),
                    label: Text(_riskLabel(level)),
                    backgroundColor: _riskColor(context, level),
                  ),
                ),
          onTap: onStudentTap == null ? null : () => onStudentTap!(entry),
        );
      },
    );
  }
}
