import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'admin/placement/placement_repository.dart';
import 'admin/placement/placement_screen.dart';
import 'functions/console_functions.dart';
import 'shared/relationship_diagram/diagram_tab.dart';
import 'shells/admin_shell.dart';
import 'shells/no_access_screen.dart';
import 'shells/teacher_shell.dart';
import 'teacher/fit/fit_repository.dart';
import 'teacher/fit/fit_screen.dart';
import 'teacher/roster/exam_paper_repository.dart';
import 'teacher/roster/exam_paper_upload.dart';
import 'teacher/roster/student_detail.dart';

/// Bridges the gateway's claim stream to the [Listenable] go_router needs in
/// order to re-run `redirect` when the session changes.
class _ClaimsListenable extends ChangeNotifier {
  _ClaimsListenable(Stream<SessionClaims?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<SessionClaims?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Routes by the `user_role` claim.
///
/// The gateway is injected rather than read from a global, so routing can be
/// tested against a fake with no Supabase session and no network.
GoRouter buildConsoleRouter({
  required AuthGateway gateway,
  required SyncEduDatabase db,
  SupabaseClient? supabase,
}) {
  final ConsoleFunctions functions = ConsoleFunctions(supabase);
  String schoolId() => gateway.currentClaims?.schoolId ?? 'school';
  String userId() => gateway.currentClaims?.userId ?? '';

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _ClaimsListenable(gateway.claimsChanges),
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => SignInScreen(gateway: gateway)),
      GoRoute(
        path: '/sign-in',
        builder: (_, _) => SignInScreen(gateway: gateway),
      ),
      GoRoute(
        path: '/teacher',
        redirect: (_, _) => '/teacher/curriculum',
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return TeacherShell(
            gateway: gateway,
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/teacher/curriculum',
                builder: (_, _) => TeacherCurriculumTab(db: db),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/teacher/schedule',
                builder: (_, _) => TeacherScheduleTab(db: db),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/teacher/analytics',
                builder: (_, _) => TeacherAnalyticsTab(db: db),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/teacher/teaching',
                builder: (_, _) => TeacherTeachingTab(
                  db: db,
                  functions: functions,
                  schoolId: schoolId(),
                  teacherId: userId(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/teacher/roster',
                builder: (_, _) => TeacherRosterTab(db: db),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'students/:studentId',
                    builder: (BuildContext context, GoRouterState state) {
                      return StudentDetail(
                        progress: const <ProgressPoint>[],
                        retryChains: const <RetryChain>[],
                        struggleTags: const <ConceptRank>[],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        redirect: (_, _) => '/admin/overview',
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AdminShell(
            gateway: gateway,
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/overview',
                builder: (_, _) => AdminOverviewTab(db: db),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/risk',
                builder: (_, _) => AdminRiskTab(db: db),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/admin/management',
                builder: (_, _) => AdminManagementTab(db: db),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin/placement',
        builder: (_, _) => PlacementScreen(
          repository: PlacementRepository(db: db, functions: functions),
          schoolId: schoolId(),
        ),
      ),
      GoRoute(
        path: '/admin/diagram',
        builder: (_, _) =>
            RelationshipDiagramTab(db: db, schoolId: schoolId()),
      ),
      GoRoute(
        path: '/teacher/diagram',
        builder: (_, _) => RelationshipDiagramTab(
          db: db,
          schoolId: schoolId(),
          teacherId: userId(),
        ),
      ),
      GoRoute(
        path: '/teacher/fit/:studentId',
        builder: (BuildContext context, GoRouterState state) => FitScreen(
          repository: FitRepository(db: db, functions: functions),
          schoolId: schoolId(),
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '/teacher/roster/students/:studentId/exam-paper',
        builder: (BuildContext context, GoRouterState state) {
          final String studentId = state.pathParameters['studentId']!;
          final ExamPaperRepository repo = ExamPaperRepository(
            db: db,
            uploadedBy: userId(),
            supabase: supabase,
          );
          return Scaffold(
            appBar: AppBar(title: const Text('Exam paper')),
            body: FutureBuilder<List<(String, String)>>(
              future: repo.chapterOptions(schoolId()),
              builder: (BuildContext context,
                  AsyncSnapshot<List<(String, String)>> snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ExamPaperUpload(
                    repository: repo,
                    schoolId: schoolId(),
                    studentId: studentId,
                    chapters: snapshot.data ?? const <(String, String)>[],
                  ),
                );
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/no-access',
        builder: (_, _) => NoAccessScreen(gateway: gateway),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final SessionClaims? claims = gateway.currentClaims;
      final String location = state.matchedLocation;

      if (claims == null) {
        return location == '/sign-in' ? null : '/sign-in';
      }

      final String destination = switch (claims.role) {
        UserRole.teacher => '/teacher',
        UserRole.admin => '/admin',
        UserRole.student => '/no-access',
      };

      // The set of URL prefixes this role's claim is allowed to be on.
      // Admins are allowed both areas (they can see everything a teacher
      // sees, plus school-wide management); teachers and students are
      // confined to their own single area. A prefix check (rather than
      // exact match) lets a claim's allowed area(s) cover nested routes
      // (e.g. `/teacher/curriculum` counts as "already in the teacher
      // area"), while still refusing a URL typed under an area the claim
      // has no access to -- a teacher claim on `/admin/management` does
      // not start with `/teacher`, so the guard still fires and sends them
      // back to their own area.
      final List<String> allowedPrefixes = switch (claims.role) {
        UserRole.admin => const <String>['/admin', '/teacher'],
        UserRole.teacher => const <String>['/teacher'],
        UserRole.student => const <String>['/no-access'],
      };

      final bool alreadyAllowed = allowedPrefixes.any((String prefix) =>
          location == prefix || location.startsWith('$prefix/'));

      return alreadyAllowed ? null : destination;
    },
  );
}
