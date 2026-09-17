import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import '../teacher/analytics/ai_summary_panel.dart';
import '../teacher/analytics/mastery_heatmap.dart';
import '../teacher/analytics/most_missed_panel.dart';
import '../teacher/curriculum/subject_list.dart';
import '../teacher/roster/class_roster.dart';
import '../teacher/schedule/schedule_editor.dart';
import '../functions/console_functions.dart';
import '../teacher/teaching/teaching_repository.dart';
import '../teacher/teaching/teaching_screen.dart';

/// The navigation shell for a signed-in teacher.
///
/// Each of the five sections below (curriculum, schedule, analytics,
/// teaching, roster) is a nested `GoRoute` rather than an in-shell tab switch,
/// which
/// is what lets a student's detail screen be deep-linked to directly (as
/// `/teacher/roster/students/:studentId`) with the roster left underneath
/// it on the navigation stack. [navigationShell] is go_router's own
/// `StatefulShellRoute` handle, so switching sections here preserves each
/// branch's own navigation state (e.g. leaving a student's detail open on
/// the roster branch while browsing schedule).
class TeacherShell extends StatelessWidget {
  const TeacherShell({
    super.key,
    required this.gateway,
    required this.navigationShell,
  });

  final AuthGateway gateway;
  final StatefulNavigationShell navigationShell;

  static const List<String> _labels = <String>[
    'Curriculum',
    'Schedule',
    'Analytics',
    'Teaching',
    'Roster',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.menu_book,
    Icons.calendar_month,
    Icons.insights,
    Icons.co_present,
    Icons.groups,
  ];

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 720;

    final Widget body = navigationShell;

    if (wide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SyncEdu — Teacher'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => gateway.signOut(),
            ),
          ],
        ),
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) =>
                  navigationShell.goBranch(index),
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                for (int i = 0; i < _labels.length; i++)
                  NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    label: Text(_labels[i]),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncEdu — Teacher'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => gateway.signOut(),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(index),
        destinations: <NavigationDestination>[
          for (int i = 0; i < _labels.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _labels[i]),
        ],
      ),
    );
  }
}

/// Owns the local repositories used by the teacher tabs, built off the
/// shared local mirror.
///
/// [db] is injected rather than opened with `SyncEduDatabase.open()` here,
/// so the whole shell tree stays testable with an in-memory
/// `SyncEduDatabase.forTesting()` and the router never has to know how the
/// real app's database was constructed -- `main.dart` owns that decision
/// and hands the single, already-opened instance down.
class TeacherCurriculumTab extends StatelessWidget {
  const TeacherCurriculumTab({super.key, required this.db});

  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    final CurriculumRepository repository = CurriculumRepository(
      db,
      OutboxWriter(db),
      InMemoryMaterialBlobStore(),
    );
    return SubjectList(
      repository: repository,
      schoolId: 'school',
      teacherId: 'teacher',
    );
  }
}

class TeacherScheduleTab extends StatelessWidget {
  const TeacherScheduleTab({super.key, required this.db});

  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    final CurriculumRepository repository = CurriculumRepository(
      db,
      OutboxWriter(db),
      InMemoryMaterialBlobStore(),
    );
    return ScheduleEditor(
      repository: repository,
      schoolId: 'school',
      classId: 'class',
    );
  }
}

/// Analytics landing tab. A future task wires live drift-streamed figures
/// into these three panels; for now they render with empty/placeholder data
/// so the navigation structure and route guard can be exercised without a
/// full analytics data pipeline.
class TeacherAnalyticsTab extends StatelessWidget {
  const TeacherAnalyticsTab({super.key, required this.db});

  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const MasteryHeatmap(cells: <MasteryCell>[]),
        const SizedBox(height: 24),
        const MostMissedPanel(ranked: <ConceptRank>[]),
        const SizedBox(height: 24),
        AiSummaryPanel(generate: () async => ''),
      ],
    );
  }
}

/// The teaching review tab.
///
/// Unlike the placeholder tabs above this one takes its ids from the router
/// rather than hard-coding them: the review is scoped to the signed-in
/// teacher's own classes, so a wrong id here would not render empty, it would
/// render someone else's classes.
class TeacherTeachingTab extends StatelessWidget {
  const TeacherTeachingTab({
    super.key,
    required this.db,
    required this.functions,
    required this.schoolId,
    required this.teacherId,
  });

  final SyncEduDatabase db;
  final ConsoleFunctions functions;
  final String schoolId;
  final String teacherId;

  @override
  Widget build(BuildContext context) {
    return TeachingScreen(
      repository: TeachingRepository(
        db: db,
        functions: functions,
        teacherId: teacherId,
      ),
      schoolId: schoolId,
    );
  }
}

class TeacherRosterTab extends StatelessWidget {
  const TeacherRosterTab({super.key, required this.db});

  final SyncEduDatabase db;

  @override
  Widget build(BuildContext context) {
    return ClassRoster(
      entries: const <RosterEntry>[],
      onStudentTap: (RosterEntry entry) {
        context.go('/teacher/roster/students/${entry.studentId}');
      },
    );
  }
}
