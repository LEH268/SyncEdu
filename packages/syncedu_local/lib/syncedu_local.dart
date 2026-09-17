/// Local SQLite mirror, outbox and sync engine for SyncEdu.
library;

export 'src/auth/sign_in_screen.dart';
export 'src/auth/supabase_auth_gateway.dart';
// `Material` (the generated `materials` row class) is hidden here because it
// collides with Flutter's own `Material` widget in any file that imports
// both packages. Use `MaterialRecord` from curriculum_repository.dart
// instead -- it is a typedef for the same class.
export 'src/db/database.dart' hide Material;
export 'src/db/tables/mirror_tables.dart';
export 'src/db/tables/sync_tables.dart';
export 'src/repository/analytics_repository.dart';
export 'src/repository/curriculum_repository.dart';
export 'src/repository/management_repository.dart';
export 'src/repository/observation_repository.dart';
export 'src/repository/quiz_repository.dart';
export 'src/sync/connectivity.dart';
export 'src/sync/outbox_writer.dart';
export 'src/sync/puller.dart';
export 'src/sync/pusher.dart';
export 'src/sync/remote_gateway.dart';
export 'src/sync/supabase_remote_gateway.dart';
export 'src/sync/sync_descriptor.dart';
export 'src/sync/sync_engine.dart';
export 'src/testing/fake_auth_gateway.dart';
export 'src/testing/fake_remote_gateway.dart';
export 'src/testing/seed_helpers.dart';
