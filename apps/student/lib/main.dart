import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:syncedu_local/syncedu_local.dart';

import 'router.dart';
import 'voice/chat_service.dart';
import 'widgets/emoji_scope.dart';
import 'widgets/sync_banner.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    throw StateError(
      'Run with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  runApp(const SyncEduStudent());
}

class SyncEduStudent extends StatefulWidget {
  const SyncEduStudent({super.key});

  @override
  State<SyncEduStudent> createState() => _SyncEduStudentState();
}

class _SyncEduStudentState extends State<SyncEduStudent> {
  late final SyncEduDatabase _db = SyncEduDatabase.open();
  late final SupabaseAuthGateway _gateway =
      SupabaseAuthGateway(Supabase.instance.client);
  late final SupabaseRemoteGateway _remote =
      SupabaseRemoteGateway(Supabase.instance.client);
  late final SyncEngine _engine = SyncEngine(
    db: _db,
    puller: Puller(_db, _remote, defaultDescriptors),
    pusher: Pusher(_db, _remote),
    connectivity: connectivityStream(),
  )..start();

  late final ChatService _chatService = ChatService(
    database: _db,
    supabase: Supabase.instance.client,
    gateway: _gateway,
  );

  late final routerConfig = buildStudentRouter(
    gateway: _gateway,
    database: _db,
    chatService: _chatService,
    supabase: Supabase.instance.client,
  );

  @override
  void dispose() {
    unawaited(_engine.dispose());
    unawaited(_db.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SyncEdu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BE8)),
        useMaterial3: true,
      ),
      routerConfig: routerConfig,
      builder: (BuildContext context, Widget? child) {
        return EmojiScope(
          child: StreamBuilder<SyncStatus>(
            stream: _engine.status,
            builder: (BuildContext context, AsyncSnapshot<SyncStatus> snapshot) {
              final SyncStatus? status = snapshot.data;
              return Column(
                children: <Widget>[
                  if (status != null) SyncBanner(status: status),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
