import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

import 'content_models.dart';

/// Reads generated revision content from the local mirror and, when online,
/// asks `generate-content` for more. Reads never touch the network; a cached
/// deck or story opens with no connection.
class ContentRepository {
  ContentRepository({
    required this.database,
    required this.supabase,
    required this.gateway,
  });

  final SyncEduDatabase database;
  final SupabaseClient supabase;
  final AuthGateway gateway;

  String get _schoolId => gateway.currentClaims!.schoolId;
  String get _profileId => gateway.currentClaims!.userId;

  Future<String?> studentId() async {
    final Student? row = await (database.select(database.students)
          ..where(($StudentsTable t) =>
              t.profileId.equals(_profileId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.id;
  }

  Future<Chapter?> chapterForOrdinal(int ordinal) =>
      (database.select(database.chapters)
            ..where(($ChaptersTable t) =>
                t.schoolId.equals(_schoolId) &
                t.ordinal.equals(ordinal) &
                t.deletedAt.isNull()))
          .getSingleOrNull();

  /// prep before the class has been taught the chapter, revise after.
  Future<String> modeForChapter(String chapterId) async {
    final ClassChapterSchedData? taught =
        await (database.select(database.classChapterSched)
              ..where(($ClassChapterSchedTable t) =>
                  t.chapterId.equals(chapterId) &
                  t.taughtOn.isNotNull() &
                  t.deletedAt.isNull()))
            .getSingleOrNull();
    return taught == null ? 'prep' : 'revise';
  }

  /// The newest cached row for a chapter/kind — a row generated for this
  /// student if there is one, otherwise a shared row.
  Future<GeneratedContentData?> cached({
    required String chapterId,
    required ContentKind kind,
    required String studentId,
  }) async {
    final List<GeneratedContentData> rows =
        await (database.select(database.generatedContent)
              ..where(($GeneratedContentTable t) =>
                  t.chapterId.equals(chapterId) &
                  t.kind.equals(kind.wire) &
                  t.deletedAt.isNull() &
                  (t.studentId.equals(studentId) | t.studentId.isNull()))
              ..orderBy(<OrderClauseGenerator<$GeneratedContentTable>>[
                ($GeneratedContentTable t) => OrderingTerm(
                      expression: t.studentId.isNull(),
                    ),
                ($GeneratedContentTable t) => OrderingTerm.desc(t.updatedAt),
              ]))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Asks `generate-content` for a fresh deck / story / note set. Requires a
  /// connection by nature. The server persists the row; we also write it
  /// locally so it is available immediately and offline afterwards.
  Future<GeneratedContentData> generate({
    required String chapterId,
    required ContentKind kind,
    required String studentId,
    String mode = 'revise',
    List<String>? microSkillIds,
  }) async {
    final FunctionResponse response = await supabase.functions.invoke(
      'generate-content',
      body: <String, dynamic>{
        'kind': kind.wire,
        'chapterId': chapterId,
        'studentId': studentId,
        'mode': mode,
        'microSkillIds': ?microSkillIds,
      },
    );
    final Map<String, dynamic> data =
        (response.data as Map<dynamic, dynamic>).cast<String, dynamic>();
    final String id = data['id'] as String;
    final String payload = jsonEncode(data['payload']);
    final DateTime now = DateTime.now().toUtc();

    await database.into(database.generatedContent).insert(
          GeneratedContentCompanion.insert(
            id: id,
            schoolId: _schoolId,
            chapterId: chapterId,
            studentId: Value(studentId),
            kind: kind.wire,
            payload: Value(payload),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    return (await (database.select(database.generatedContent)
              ..where(($GeneratedContentTable t) => t.id.equals(id)))
            .getSingle());
  }
}
