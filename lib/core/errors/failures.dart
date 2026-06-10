/// Typed failure classes used throughout the domain layer.
/// UI receives these via Either<Failure, T> — never raw exceptions.
abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

// ─── Network ───────────────────────────────────────────────
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.', super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out.', super.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

// ─── Auth ──────────────────────────────────────────────────
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorized. Please sign in again.', super.code = 401});
}

// ─── Location ──────────────────────────────────────────────
class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure({super.message = 'Location permission denied.'});
}

class LocationPermissionPermanentlyDeniedFailure extends Failure {
  const LocationPermissionPermanentlyDeniedFailure({
    super.message = 'Location permission permanently denied. Enable in Settings.',
  });
}

class LocationTimeoutFailure extends Failure {
  const LocationTimeoutFailure({super.message = 'Could not get your location in time.'});
}

// ─── City ──────────────────────────────────────────────────
class NoCitySelectedFailure extends Failure {
  const NoCitySelectedFailure({super.message = 'No city selected. Please choose a city.'});
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure({super.message = 'City not found.'});
}

class OutsideServiceAreaFailure extends Failure {
  const OutsideServiceAreaFailure({
    super.message = 'You appear to be outside a supported city.',
  });
}

// ─── Business Logic ────────────────────────────────────────
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class TooManyReportsFailure extends Failure {
  const TooManyReportsFailure({
    super.message = 'You already submitted a report for this bus recently.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Could not read cached data.'});
}

class OfflineFailure extends Failure {
  const OfflineFailure({
    super.message = 'You are offline. Showing saved data.',
  });
}

// ─── Bluetooth ─────────────────────────────────────────────
class BluetoothFailure extends Failure {
  const BluetoothFailure({
    super.message = 'Bluetooth unavailable or permission denied.',
  });
}

class BluetoothOffFailure extends Failure {
  const BluetoothOffFailure({
    super.message = 'Bluetooth is turned off. Enable it to share location with nearby commuters.',
  });
}

class NoPeersFailure extends Failure {
  const NoPeersFailure({
    super.message = 'No nearby commuters found via Bluetooth.',
  });
}
