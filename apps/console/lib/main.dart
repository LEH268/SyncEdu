import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:syncedu_local/syncedu_local.dart';

import 'router.dart';
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

  runApp(const SyncEduConsole());
}

class SyncEduConsole extends StatefulWidget {
  const SyncEduConsole({super.key});

  @override
  State<SyncEduConsole> createState() => _SyncEduConsoleState();
}

class _SyncEduConsoleState extends State<SyncEduConsole> {
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

  late final routerConfig = buildConsoleRouter(
    gateway: _gateway,
    db: _db,
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
      title: 'SyncEdu Console',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BE8)),
        useMaterial3: true,
      ),
      routerConfig: routerConfig,
      builder: (BuildContext context, Widget? child) {
        return StreamBuilder<SyncStatus>(
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
        );
      },
    );
  }
}
