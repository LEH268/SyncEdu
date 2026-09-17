import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'chat_controller.dart';

/// One chapter as the chat surface needs it: its local id, its ordinal, its
/// title, and whether it has been taught to any class yet (revision vs.
/// preview).
class ChatChapter {
  const ChatChapter({
    required this.id,
    required this.ordinal,
    required this.title,
    required this.taught,
  });

  final String id;
  final int ordinal;
  final String title;
  final bool taught;
}

/// Bridges the chat UI to the local mirror and the `chat` Edge Function.
///
/// Everything the model needs -- the chapter list, the taught/untaught state,
/// the student's name -- is read from local drift tables, so building the
/// request never touches the network; only [sendToChat] does.
class ChatService {
  ChatService({
    required this.database,
    required this._supabase,
    required this._gateway,
  });

  final SyncEduDatabase database;
  final SupabaseClient _supabase;
  final AuthGateway _gateway;

  String get schoolId => _gateway.currentClaims!.schoolId;
  String get profileId => _gateway.currentClaims!.userId;

  Future<List<ChatChapter>> chapters() async {
    final List<Chapter> rows = await (database.select(database.chapters)
          ..where(($ChaptersTable t) =>
              t.schoolId.equals(schoolId) & t.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$ChaptersTable>>[
            ($ChaptersTable t) => OrderingTerm.asc(t.ordinal),
          ]))
        .get();

    final List<ClassChapterSchedData> sched =
        await (database.select(database.classChapterSched)
              ..where(($ClassChapterSchedTable t) =>
                  t.schoolId.equals(schoolId) & t.taughtOn.isNotNull()))
            .get();
    final Set<String> taught =
        sched.map((ClassChapterSchedData s) => s.chapterId).toSet();

    return <ChatChapter>[
      for (final Chapter c in rows)
        ChatChapter(
          id: c.id,
          ordinal: c.ordinal,
          title: c.title,
          taught: taught.contains(c.id),
        ),
    ];
  }

  Future<List<int>> chapterOrdinals() async =>
      (await chapters()).map((ChatChapter c) => c.ordinal).toList();

  /// The local chapter ids for a set of ordinals, in the order given, skipping
  /// any ordinal that does not resolve.
  Future<List<String>> chapterIdsForOrdinals(List<int> ordinals) async {
    final List<ChatChapter> all = await chapters();
    final Map<int, String> byOrdinal = <int, String>{
      for (final ChatChapter c in all) c.ordinal: c.id,
    };
    return <String>[
      for (final int ordinal in ordinals)
        if (byOrdinal.containsKey(ordinal)) byOrdinal[ordinal]!,
    ];
  }

  ChatSender get sendToChat => (String utterance) async {
    final List<ChatChapter> all = await chapters();
    final Profile? profile = await (database.select(database.profiles)
          ..where(($ProfilesTable t) => t.id.equals(profileId)))
        .getSingleOrNull();

    final FunctionResponse response = await _supabase.functions.invoke(
      'chat',
      body: <String, dynamic>{
        'utterance': utterance,
        'studentName': profile?.fullName ?? 'there',
        'chapters': <Map<String, dynamic>>[
          for (final ChatChapter c in all)
            <String, dynamic>{
              'ordinal': c.ordinal,
              'title': c.title,
              'taught': c.taught,
            },
        ],
      },
    );

    final Map<String, dynamic> data =
        (response.data as Map<dynamic, dynamic>).cast<String, dynamic>();
    final Map<String, dynamic>? rawCall =
        (data['toolCall'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>();

    return ChatResponse(
      reply: (data['reply'] as String?) ?? '',
      toolCall: rawCall == null
          ? null
          : toolCallFromJson(
              rawCall['name'] as String,
              (rawCall['args'] as Map<dynamic, dynamic>? ?? <String, dynamic>{})
                  .cast<String, dynamic>(),
            ),
    );
  };
}
