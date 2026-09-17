import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_local/syncedu_local.dart';
import 'package:uuid/uuid.dart';

/// Opens and closes a Year-End Reflection campaign. Opening one is all it
/// takes: the student app raises the reflection on next launch through the
/// router gate (spec §7.4). Tier-1 insert; closing is a single-owner mutable
/// field, written as a tier-2 delta.
class ReflectionCampaignRepository {
  ReflectionCampaignRepository(this._db) : _outbox = OutboxWriter(_db);

  final SyncEduDatabase _db;
  final OutboxWriter _outbox;
  static const Uuid _uuid = Uuid();

  Stream<List<ReflectionCampaign>> watch(String schoolId) =>
      (_db.select(_db.reflectionCampaigns)
            ..where(($ReflectionCampaignsTable t) =>
                t.schoolId.equals(schoolId) & t.deletedAt.isNull())
            ..orderBy(<OrderClauseGenerator<$ReflectionCampaignsTable>>[
              ($ReflectionCampaignsTable t) => OrderingTerm.desc(t.openedAt),
            ]))
          .watch();

  Future<void> open({required String schoolId, required String academicYear}) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    await _db.into(_db.reflectionCampaigns).insert(
          ReflectionCampaignsCompanion.insert(
            id: id,
            schoolId: schoolId,
            academicYear: academicYear,
            openedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await _outbox.queueInsert(
      table: 'reflection_campaigns',
      row: <String, dynamic>{
        'id': id,
        'school_id': schoolId,
        'academic_year': academicYear,
        'opened_at': now.toIso8601String(),
      },
    );
  }

  Future<void> close(ReflectionCampaign campaign) async {
    final DateTime now = DateTime.now().toUtc();
    await (_db.update(_db.reflectionCampaigns)
          ..where(($ReflectionCampaignsTable t) => t.id.equals(campaign.id)))
        .write(ReflectionCampaignsCompanion(closedAt: Value(now)));
    await _outbox.queueDelta(
      table: 'reflection_campaigns',
      rowId: campaign.id,
      field: 'closed_at',
      observedValue: campaign.closedAt?.toIso8601String(),
      newValue: now.toIso8601String(),
    );
  }
}

class ReflectionCampaignPanel extends StatefulWidget {
  const ReflectionCampaignPanel({
    super.key,
    required this.repository,
    required this.schoolId,
  });

  final ReflectionCampaignRepository repository;
  final String schoolId;

  @override
  State<ReflectionCampaignPanel> createState() =>
      _ReflectionCampaignPanelState();
}

class _ReflectionCampaignPanelState extends State<ReflectionCampaignPanel> {
  final TextEditingController _year = TextEditingController(
    text: '${DateTime.now().year}',
  );

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Year-End Reflection', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Opening a campaign prompts every student to complete the reflection '
          'on their next launch. It feeds the 30% student component of the '
          'Class Fit Analyzer.',
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            SizedBox(
              width: 140,
              child: TextField(
                key: const Key('campaign-year'),
                controller: _year,
                decoration: const InputDecoration(
                  labelText: 'Academic year',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              key: const Key('campaign-open'),
              onPressed: () => widget.repository.open(
                schoolId: widget.schoolId,
                academicYear: _year.text.trim(),
              ),
              child: const Text('Open campaign'),
            ),
          ],
        ),
        const Divider(height: 32),
        StreamBuilder<List<ReflectionCampaign>>(
          stream: widget.repository.watch(widget.schoolId),
          builder: (BuildContext context,
              AsyncSnapshot<List<ReflectionCampaign>> snapshot) {
            final List<ReflectionCampaign> campaigns =
                snapshot.data ?? const <ReflectionCampaign>[];
            if (campaigns.isEmpty) {
              return const Text('No campaigns yet.');
            }
            return Column(
              children: <Widget>[
                for (final ReflectionCampaign c in campaigns)
                  ListTile(
                    key: Key('campaign-${c.id}'),
                    title: Text(c.academicYear),
                    subtitle:
                        Text(c.closedAt == null ? 'Open' : 'Closed'),
                    trailing: c.closedAt == null
                        ? TextButton(
                            onPressed: () => widget.repository.close(c),
                            child: const Text('Close'),
                          )
                        : null,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          children: <Widget>[
            OutlinedButton(
              onPressed: () => context.go('/admin/placement'),
              child: const Text('Placement preview'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/admin/diagram'),
              child: const Text('Class structure'),
            ),
          ],
        ),
      ],
    );
  }
}
