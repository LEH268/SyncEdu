import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_console/admin/reflection/reflection_campaign_panel.dart';
import 'package:syncedu_local/syncedu_local.dart';

void main() {
  late SyncEduDatabase db;
  late ReflectionCampaignRepository repo;

  setUp(() {
    db = SyncEduDatabase.forTesting();
    repo = ReflectionCampaignRepository(db);
  });
  tearDown(() => db.close());

  test('opening a campaign inserts a row and queues it for sync', () async {
    await repo.open(schoolId: 's', academicYear: '2026');

    final row = await db.select(db.reflectionCampaigns).getSingle();
    expect(row.academicYear, '2026');
    expect(row.closedAt, isNull);

    final outbox = await db.select(db.outbox).get();
    expect(outbox.any((o) => o.table == 'reflection_campaigns'), isTrue);
  });

  test('closing a campaign sets closedAt and queues a tier-2 delta', () async {
    await repo.open(schoolId: 's', academicYear: '2026');
    final row = await db.select(db.reflectionCampaigns).getSingle();

    await repo.close(row);

    final updated = await db.select(db.reflectionCampaigns).getSingle();
    expect(updated.closedAt, isNotNull);

    final outbox = await db.select(db.outbox).get();
    expect(outbox.any((o) => o.field == 'closed_at'), isTrue);
  });
}
