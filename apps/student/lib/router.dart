import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_emoji/syncedu_emoji.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'activities/activity_loader.dart';
import 'activities/content_models.dart';
import 'activities/content_repository.dart';
import 'activities/flashcards/flashcard_deck_screen.dart';
import 'activities/story/story_screen.dart';
import 'onboarding/onboarding_gate.dart';
import 'onboarding/onboarding_repository.dart';
import 'onboarding/pre_admission_screen.dart';
import 'onboarding/year_end_reflection.dart';
import 'quiz/chapter_picker.dart';
import 'quiz/quiz_controller.dart';
import 'quiz/quiz_result.dart';
import 'quiz/quiz_runner.dart';
import 'quiz/targeted_notes.dart';
import 'shells/home_shell.dart';
import 'shells/learn_shell.dart';
import 'shells/staff_redirect_screen.dart';
import 'voice/chat_service.dart';
import 'voice/quiz_starter.dart';
import 'widgets/coming_soon.dart';
import 'widgets/emoji_scope.dart';

List<int> _ordinalsParam(GoRouterState state) {
  final String raw = state.uri.queryParameters['chapters'] ?? '';
  return <int>[
    for (final String part in raw.split(','))
      if (int.tryParse(part.trim()) case final int n) n,
  ];
}

/// Shown on a gate route before the student's own row has synced to this
/// device — the one case where the interrupt cannot yet be built.
class _WaitingForStudentRow extends StatelessWidget {
  const _WaitingForStudentRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Connect once so your record can finish syncing, then this will '
            'open automatically.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

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

/// Resolves the signed-in profile to its `students.id` before building
/// anything that needs a [QuizController].
///
/// The JWT's user id is `profiles.id`; the quiz pool, the weakness store and
/// the attempt tables all key off `students.id`, a different uuid reached via
/// `students.profile_id`. Passing the wrong one fails silently (every mode
/// reads as `prep`, no personalised item ever surfaces) or throws on submit,
/// so the two are never allowed to be conflated here.
///
/// The student row arrives through the ordinary mirror pull, so on a first
/// launch it may not be there yet -- that is a "still syncing" state, not an
/// error, and certainly not grounds for falling back to the profile id.
class _QuizScope extends StatefulWidget {
  const _QuizScope({
    required this.profileId,
    required this.repository,
    required this.controllerFor,
    required this.builder,
  });

  final String profileId;
  final QuizRepository repository;
  final QuizController Function(String studentId) controllerFor;
  final Widget Function(BuildContext context, QuizController controller) builder;

  @override
  State<_QuizScope> createState() => _QuizScopeState();
}

class _QuizScopeState extends State<_QuizScope> {
  late final Future<String?> _studentId =
      widget.repository.studentIdForProfile(widget.profileId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _studentId,
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final String? studentId = snapshot.data;
        if (studentId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Almost ready')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Your student record has not finished syncing to this '
                      'device yet. Connect once, then try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      key: const Key('quiz-unready-home'),
                      onPressed: () => context.go('/home'),
                      child: const Text('Back to home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return widget.builder(context, widget.controllerFor(studentId));
      },
    );
  }
}

/// Routes by the `user_role` claim. The mirror image of the console's rule:
/// students belong here, staff are pointed at the web console.
/// Route locations a signed-in student is always entitled to reach -- the
/// quiz flow and the conversational tool destinations. Redirecting away from
/// "not /home" would bounce them straight out of any of these.
const Set<String> _studentSurfaces = <String>{
  '/learn',
  '/flashcards',
  '/story',
  '/notes',
  '/progress',
};

GoRouter buildStudentRouter({
  required AuthGateway gateway,
  required SyncEduDatabase database,
  ChatService? chatService,
  SupabaseClient? supabase,
}) {
  final QuizRepository repository =
      QuizRepository(database, OutboxWriter(database));
  final ContentRepository? contentRepository = supabase == null
      ? null
      : ContentRepository(
          database: database,
          supabase: supabase,
          gateway: gateway,
        );
  final OnboardingRepository onboardingRepository = OnboardingRepository(database);
  final OnboardingState onboarding = OnboardingState(
    repository: onboardingRepository,
    gateway: gateway,
  );
  QuizController? activeController;

  // One controller per signed-in student. `startQuiz` resets the attempt
  // chain and the submitted flag, so a new range starts clean without
  // swapping the instance out from under a screen that is holding a
  // reference to it -- but if the resolved student differs from whoever the
  // cached controller was built for (sign-out/sign-in as a different
  // student), the cache must be discarded rather than reused, or the new
  // student's answers/attempts/weakness writes get filed under the old
  // student's ids.
  QuizController controllerFor(String studentId) {
    if (activeController != null && activeController!.studentId != studentId) {
      activeController = null;
    }
    return activeController ??= QuizController(
      repository: repository,
      studentId: studentId,
      schoolId: gateway.currentClaims!.schoolId,
    );
  }

  Widget quizScope(
    Widget Function(BuildContext context, QuizController controller) builder,
  ) =>
      _QuizScope(
        profileId: gateway.currentClaims!.userId,
        repository: repository,
        controllerFor: controllerFor,
        builder: builder,
      );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge(
      <Listenable>[_ClaimsListenable(gateway.claimsChanges), onboarding],
    ),
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => SignInScreen(gateway: gateway)),
      GoRoute(
        path: '/sign-in',
        builder: (_, _) => SignInScreen(gateway: gateway),
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) =>
            HomeShell(gateway: gateway, chatService: chatService),
      ),
      GoRoute(
        path: '/learn',
        builder: (_, _) => LearnShell(chatService: chatService),
      ),
      GoRoute(
        path: '/pre-admission',
        builder: (BuildContext context, _) {
          final String? studentId = onboarding.studentId;
          if (studentId == null) {
            return const _WaitingForStudentRow(title: 'Pre-admission Test');
          }
          return PreAdmissionScreen(
            repository: onboardingRepository,
            studentId: studentId,
            schoolId: gateway.currentClaims!.schoolId,
            onComplete: (_) => context.go('/home'),
          );
        },
      ),
      GoRoute(
        path: '/year-end-reflection',
        builder: (BuildContext context, _) {
          final String? studentId = onboarding.studentId;
          if (studentId == null) {
            return const _WaitingForStudentRow(title: 'Year-End Reflection');
          }
          return FutureBuilder<ReflectionCampaign?>(
            future: onboardingRepository.openUnansweredCampaign(studentId),
            builder: (BuildContext context, AsyncSnapshot<ReflectionCampaign?> snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final ReflectionCampaign? campaign = snap.data;
              if (campaign == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.go('/home');
                });
                return const Scaffold(body: SizedBox.shrink());
              }
              return YearEndReflectionScreen(
                repository: onboardingRepository,
                studentId: studentId,
                schoolId: gateway.currentClaims!.schoolId,
                campaign: campaign,
                onComplete: () => context.go('/home'),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/quiz/start',
        builder: (BuildContext context, GoRouterState state) => quizScope(
          (BuildContext context, QuizController controller) => QuizStarter(
            database: database,
            schoolId: gateway.currentClaims!.schoolId,
            controller: controller,
            chapterOrdinals: _ordinalsParam(state),
            count: int.tryParse(state.uri.queryParameters['count'] ?? '') ?? 10,
          ),
        ),
      ),
      GoRoute(
        path: '/flashcards',
        builder: (BuildContext context, GoRouterState state) {
          final int? ordinal =
              int.tryParse(state.uri.queryParameters['chapter'] ?? '');
          if (ordinal == null) {
            return const ComingSoon(
              title: 'Flashcards',
              detail: 'Ask for a chapter, e.g. "flashcards for chapter 2".',
            );
          }
          return ActivityLoader(
            repository: contentRepository,
            chapterOrdinal: ordinal,
            kind: ContentKind.flashcards,
            builder: (BuildContext context, content, List<String> needs) =>
                FlashcardDeckScreen(
              deck: FlashcardDeck.fromPayload(content.payload),
              specialNeeds: needs,
            ),
          );
        },
      ),
      GoRoute(
        path: '/story',
        builder: (BuildContext context, GoRouterState state) {
          final int? ordinal =
              int.tryParse(state.uri.queryParameters['chapter'] ?? '');
          if (ordinal == null) {
            return const ComingSoon(
              title: 'Story',
              detail: 'Ask for a chapter, e.g. "tell me a story for chapter 1".',
            );
          }
          return ActivityLoader(
            repository: contentRepository,
            chapterOrdinal: ordinal,
            kind: ContentKind.story,
            builder: (BuildContext context, content, List<String> needs) =>
                StoryScreen(
              story: Story.fromPayload(content.payload),
              specialNeeds: needs,
            ),
          );
        },
      ),
      GoRoute(
        path: '/notes',
        builder: (_, _) => const ComingSoon(title: 'Notes'),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, _) => const ComingSoon(title: 'Progress'),
      ),
      GoRoute(
        path: '/use-console',
        builder: (_, _) => StaffRedirectScreen(gateway: gateway),
      ),
      GoRoute(
        path: '/quiz/pick',
        builder: (BuildContext context, _) => quizScope(
          (BuildContext context, QuizController controller) => ChapterPicker(
            database: database,
            schoolId: gateway.currentClaims!.schoolId,
            onStart: (List<String> chapterIds) async {
              await controller.startQuiz(chapterIds: chapterIds);
              if (!context.mounted) return;
              if (controller.questions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'There are no questions for that range yet.',
                    ),
                  ),
                );
                return;
              }
              context.go('/quiz/run');
            },
          ),
        ),
      ),
      GoRoute(
        path: '/quiz/run',
        builder: (BuildContext context, _) => quizScope(
          (BuildContext context, QuizController controller) => QuizRunner(
            controller: controller,
            onComplete: () async {
              await controller.submit();
              if (!context.mounted) return;
              final int total = controller.questions.length;
              final EmojiController? emoji = EmojiScope.maybeOf(context);
              if (total > 0 && emoji != null) {
                final double fraction = controller.score / total;
                if (fraction >= 0.8) {
                  emoji.setState(EmojiState.celebrate);
                } else if (fraction < 0.4) {
                  emoji.setState(EmojiState.sad);
                }
              }
              context.go('/quiz/result');
            },
            onNewRange: () => context.go('/quiz/pick'),
          ),
        ),
      ),
      GoRoute(
        path: '/quiz/result',
        builder: (BuildContext context, _) => quizScope(
          (BuildContext context, QuizController controller) => QuizResult(
            controller: controller,
            onRegenerate: () async {
              await controller.regenerate();
              if (context.mounted) context.go('/quiz/run');
            },
            onPractiseMistakes: () async {
              await controller.practiseMistakes();
              if (context.mounted) context.go('/quiz/run');
            },
            onNewRange: () => context.go('/quiz/pick'),
            onNotes: () async {
              EmojiScope.maybeOf(context)?.setState(EmojiState.loading);
              await controller.generateNotes();
              if (context.mounted) context.go('/quiz/notes');
            },
          ),
        ),
      ),
      GoRoute(
        path: '/quiz/notes',
        builder: (BuildContext context, _) => quizScope(
          (BuildContext context, QuizController controller) =>
              TargetedNotes(controller: controller),
        ),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final SessionClaims? claims = gateway.currentClaims;
      final String location = state.matchedLocation;

      if (claims == null) {
        return location == '/sign-in' ? null : '/sign-in';
      }

      // Two mandatory interrupts, pre-admission first. They apply only once
      // the student row has reached this device -- until then there is
      // nothing to gate on and the app operates normally.
      if (claims.role == UserRole.student && onboarding.studentId != null) {
        if (!onboarding.preAdmissionComplete) {
          return location == '/pre-admission' ? null : '/pre-admission';
        }
        if (onboarding.reflectionDue) {
          return location == '/year-end-reflection' ? null : '/year-end-reflection';
        }
      }
      if (claims.role == UserRole.student &&
          (location == '/pre-admission' || location == '/year-end-reflection')) {
        // Gate satisfied (or not yet applicable): leave these screens.
        return '/home';
      }

      // The quiz flow is the student's, and every one of its screens is a
      // place a signed-in student is entitled to be -- redirecting on "not
      // /home" would bounce them straight back out of it.
      if (claims.role == UserRole.student &&
          (location.startsWith('/quiz/') ||
              _studentSurfaces.contains(location))) {
        return null;
      }

      final String destination = switch (claims.role) {
        UserRole.student => '/home',
        UserRole.teacher || UserRole.admin => '/use-console',
      };

      return location == destination ? null : destination;
    },
  );
}
