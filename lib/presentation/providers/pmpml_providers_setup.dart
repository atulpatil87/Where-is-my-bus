import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/pmpml/pmpml_auth_datasource.dart';
import '../../data/datasources/remote/pmpml/pmpml_directions_datasource.dart';
import '../../data/datasources/remote/pmpml/pmpml_live_datasource.dart';
import '../../data/datasources/remote/pmpml/pmpml_routes_datasource.dart';
import '../../data/datasources/remote/pmpml/pmpml_schedule_datasource.dart';
import '../../data/repositories/pmpml_repository_impl.dart';
import '../../data/repositories/i_pmpml_repository.dart';
import '../../core/network/pmpml_dio_client.dart';

// ── Dio clients ───────────────────────────────────────────────────────────────

final pmpmlTicketingDioProvider = Provider((ref) => PmpmlDioClient.ticketing());
final pmpmlRoutesDioProvider = Provider((ref) => PmpmlDioClient.routes());
final pmpmlLiveDioProvider = Provider((ref) => PmpmlDioClient.liveData());
final pmpmlDirectionsDioProvider = Provider((ref) => PmpmlDioClient.directions());
final pmpmlScheduleDioProvider = Provider((ref) => PmpmlDioClient.schedule());

// ── DataSources ───────────────────────────────────────────────────────────────

final pmpmlAuthDSProvider = Provider<PmpmlAuthDataSource>((ref) {
  return PmpmlAuthDataSource(ref.read(pmpmlTicketingDioProvider));
});

final pmpmlRoutesDSProvider = Provider<PmpmlRoutesDataSource>((ref) {
  return PmpmlRoutesDataSource(ref.read(pmpmlRoutesDioProvider));
});

final pmpmlLiveDSProvider = Provider<PmpmlLiveDataSource>((ref) {
  return PmpmlLiveDataSource(ref.read(pmpmlLiveDioProvider));
});

final pmpmlDirectionsDSProvider = Provider<PmpmlDirectionsDataSource>((ref) {
  return PmpmlDirectionsDataSource(ref.read(pmpmlDirectionsDioProvider));
});

final pmpmlScheduleDSProvider = Provider<PmpmlScheduleDataSource>((ref) {
  return PmpmlScheduleDataSource(ref.read(pmpmlScheduleDioProvider));
});

// ── Repository ────────────────────────────────────────────────────────────────

final pmpmlRepositoryProvider = Provider<IPmpmlRepository>((ref) {
  return PmpmlRepositoryImpl(
    auth: ref.read(pmpmlAuthDSProvider),
    routes: ref.read(pmpmlRoutesDSProvider),
    live: ref.read(pmpmlLiveDSProvider),
    directions: ref.read(pmpmlDirectionsDSProvider),
    schedule: ref.read(pmpmlScheduleDSProvider),
  );
});
