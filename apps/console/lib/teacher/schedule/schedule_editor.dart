import 'package:flutter/material.dart';
import 'package:syncedu_local/syncedu_local.dart';

/// Lets a teacher mark, per class, which chapters have been taught. Two
/// classes on the same subject keep entirely independent schedules -- the
/// underlying row keys off `(class_id, chapter_id)`, not just `chapter_id`
/// -- so a chapter marked taught for one class never shows as taught for
/// another.
///
/// Every write here queues a tier-2 delta on `taught_on` through
/// [CurriculumRepository]; nothing in this widget touches the network, so
/// the editor works the same whether the device is online or not. The
/// pending-writes count comes from [CurriculumRepository.watchPendingScheduleWrites]
/// rather than [SyncEngine] so the screen has no dependency on the sync
/// engine being wired up.
class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.classId,
    this.today,
  });

  final CurriculumRepository repository;
  final String schoolId;
  final String classId;

  /// Injectable so tests can pick a fixed "today" instead of depending on
  /// the wall clock.
  final DateTime Function()? today;

  DateTime _today() => (today ?? DateTime.now)();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StreamBuilder<int>(
          stream: repository.watchPendingScheduleWrites(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            final int pending = snapshot.data ?? 0;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                key: const Key('schedule-pending-count'),
                pending == 0
                    ? 'All schedule changes synced'
                    : '$pending schedule change${pending == 1 ? '' : 's'} waiting to sync',
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<ScheduleEntry>>(
            stream: repository.watchScheduleForClass(classId),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<ScheduleEntry>> snapshot,
            ) {
              final List<ScheduleEntry> entries =
                  snapshot.data ?? const <ScheduleEntry>[];
              return ListView.builder(
                key: const Key('schedule-list'),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  final ScheduleEntry entry = entries[index];
                  final bool taught = entry.taughtOn != null;
                  return ListTile(
                    key: Key('schedule-row-${entry.chapterId}'),
                    title: Text(entry.chapterTitle),
                    subtitle: Text(
                      '${entry.subjectName} · '
                      '${taught ? 'Taught ${_formatDate(entry.taughtOn!)}' : 'Not yet taught'}',
                    ),
                    trailing: taught
                        ? IconButton(
                            key: Key('schedule-clear-${entry.chapterId}'),
                            icon: const Icon(Icons.undo),
                            tooltip: 'Mark as not taught',
                            onPressed: () => repository.clearChapterTaught(
                              classId: classId,
                              chapterId: entry.chapterId,
                            ),
                          )
                        : ElevatedButton(
                            key: Key('schedule-mark-${entry.chapterId}'),
                            onPressed: () => repository.markChapterTaught(
                              schoolId: schoolId,
                              classId: classId,
                              chapterId: entry.chapterId,
                              taughtOn: _today(),
                            ),
                            child: const Text('Mark taught'),
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

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
