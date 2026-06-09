import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/network/network_info.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/bluetooth_location_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/bluetooth_location_repository_impl.dart';
import '../../domain/repositories/i_bluetooth_location_repository.dart';
import '../../domain/usecases/bluetooth/get_bluetooth_derived_location_usecase.dart';
import '../../domain/usecases/bluetooth/start_bluetooth_location_usecase.dart';
import '../../domain/usecases/bluetooth/stop_bluetooth_location_usecase.dart';
import '../../data/datasources/local/local_datasources.dart';
import '../../data/datasources/remote/bus_remote_datasource.dart';
import '../../data/datasources/remote/city_remote_datasource.dart';
import '../../data/datasources/remote/route_remote_datasource.dart';
import '../../data/datasources/remote/stop_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/bus_repository_impl.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../data/repositories/route_repository_impl.dart';
import '../../data/repositories/stop_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/i_bus_repository.dart';
import '../../domain/repositories/i_city_repository.dart';
import '../../domain/repositories/i_route_repository.dart';
import '../../domain/repositories/i_stop_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/bus/get_live_buses_usecase.dart';
import '../../domain/usecases/bus/share_bus_location_usecase.dart';
import '../../domain/usecases/city/detect_city_usecase.dart';
import '../../domain/usecases/city/get_cities_usecase.dart';
import '../../domain/usecases/route/find_route_usecase.dart';
import '../../domain/usecases/route/get_route_timetable_usecase.dart';
import '../../domain/usecases/stop/get_nearby_stops_usecase.dart';
import '../../domain/usecases/user/get_user_stats_usecase.dart';
import '../../domain/usecases/user/sign_in_usecase.dart';
import '../../domain/usecases/user/submit_crowd_report_usecase.dart';

// ─── Core ────────────────────────────────────────────────────────────────────

final networkInfoProvider = Provider<INetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final bluetoothLocationServiceProvider =
    Provider<BluetoothLocationService>((ref) {
  return BluetoothLocationService();
});

// ─── Bluetooth Location Repository ───────────────────────────────────────────

final bluetoothLocationRepositoryProvider =
    Provider<IBluetoothLocationRepository>((ref) {
  return BluetoothLocationRepositoryImpl(
    ref.read(bluetoothLocationServiceProvider),
  );
});

// ─── Bluetooth Use Cases ─────────────────────────────────────────────────────

final startBluetoothLocationUseCaseProvider =
    Provider<StartBluetoothLocationUseCase>((ref) {
  return StartBluetoothLocationUseCase(
    ref.read(bluetoothLocationRepositoryProvider),
    ref.read(locationServiceProvider),
  );
});

final stopBluetoothLocationUseCaseProvider =
    Provider<StopBluetoothLocationUseCase>((ref) {
  return StopBluetoothLocationUseCase(
    ref.read(bluetoothLocationRepositoryProvider),
  );
});

final getBluetoothDerivedLocationUseCaseProvider =
    Provider<GetBluetoothDerivedLocationUseCase>((ref) {
  return GetBluetoothDerivedLocationUseCase(
    ref.read(bluetoothLocationRepositoryProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// ─── Firebase ────────────────────────────────────────────────────────────────

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<fbauth.FirebaseAuth>((ref) {
  return fbauth.FirebaseAuth.instance;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// ─── Local DataSources ───────────────────────────────────────────────────────

final cityLocalDSProvider = Provider<CityLocalDataSource>((ref) {
  return CityLocalDataSource();
});

final timetableLocalDSProvider = Provider<TimetableLocalDataSource>((ref) {
  return TimetableLocalDataSource();
});

// ─── Remote DataSources ──────────────────────────────────────────────────────

final cityRemoteDSProvider = Provider<CityRemoteDataSource>((ref) {
  return CityRemoteDataSource(ref.read(firestoreProvider));
});

final busRemoteDSProvider = Provider<BusRemoteDataSource>((ref) {
  return BusRemoteDataSource(ref.read(firebaseDatabaseProvider));
});

final stopRemoteDSProvider = Provider<StopRemoteDataSource>((ref) {
  return StopRemoteDataSource(ref.read(firestoreProvider));
});

final routeRemoteDSProvider = Provider<RouteRemoteDataSource>((ref) {
  return RouteRemoteDataSource(ref.read(firestoreProvider));
});

final userRemoteDSProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
    ref.read(googleSignInProvider),
  );
});

// ─── Repositories ────────────────────────────────────────────────────────────

final cityRepositoryProvider = Provider<ICityRepository>((ref) {
  return CityRepositoryImpl(
    ref.read(cityRemoteDSProvider),
    ref.read(cityLocalDSProvider),
  );
});

final busRepositoryProvider = Provider<IBusRepository>((ref) {
  return BusRepositoryImpl(
    ref.read(busRemoteDSProvider),
    ref.read(firestoreProvider),
  );
});

final stopRepositoryProvider = Provider<IStopRepository>((ref) {
  return StopRepositoryImpl(ref.read(stopRemoteDSProvider));
});

final routeRepositoryProvider = Provider<IRouteRepository>((ref) {
  return RouteRepositoryImpl(
    ref.read(routeRemoteDSProvider),
    ref.read(timetableLocalDSProvider),
  );
});

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return UserRepositoryImpl(
    ref.read(userRemoteDSProvider),
    ref.read(firebaseAuthProvider),
  );
});

// ─── Use Cases ───────────────────────────────────────────────────────────────

final detectCityUseCaseProvider = Provider<DetectCityUseCase>((ref) {
  return DetectCityUseCase(
    ref.read(cityRepositoryProvider),
    ref.read(locationServiceProvider),
  );
});

final getCitiesUseCaseProvider = Provider<GetCitiesUseCase>((ref) {
  return GetCitiesUseCase(ref.read(cityRepositoryProvider));
});

final getLiveBusesUseCaseProvider = Provider<GetLiveBusesUseCase>((ref) {
  return GetLiveBusesUseCase(
    ref.read(busRepositoryProvider),
    ref.read(networkInfoProvider),
  );
});

final shareBusLocationUseCaseProvider =
    Provider<ShareBusLocationUseCase>((ref) {
  return ShareBusLocationUseCase(
    ref.read(busRepositoryProvider),
    ref.read(userRepositoryProvider),
    ref.read(locationServiceProvider),
  );
});

final getNearbyStopsUseCaseProvider = Provider<GetNearbyStopsUseCase>((ref) {
  return GetNearbyStopsUseCase(
    ref.read(stopRepositoryProvider),
    ref.read(locationServiceProvider),
  );
});

final findRouteUseCaseProvider = Provider<FindRouteUseCase>((ref) {
  return FindRouteUseCase(ref.read(routeRepositoryProvider));
});

final getRouteTimetableUseCaseProvider =
    Provider<GetRouteTimetableUseCase>((ref) {
  return GetRouteTimetableUseCase(ref.read(routeRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(userRepositoryProvider));
});

final submitCrowdReportUseCaseProvider =
    Provider<SubmitCrowdReportUseCase>((ref) {
  return SubmitCrowdReportUseCase(
    ref.read(busRepositoryProvider),
    ref.read(userRepositoryProvider),
    ref.read(locationServiceProvider),
  );
});

final getUserStatsUseCaseProvider = Provider<GetUserStatsUseCase>((ref) {
  return GetUserStatsUseCase(ref.read(userRepositoryProvider));
});
