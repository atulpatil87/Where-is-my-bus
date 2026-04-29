/// Typed exception classes thrown by data sources.
/// Caught by repositories and converted to Failure objects.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException($message, statusCode: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Network error occurred.', super.statusCode});
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timed out.', super.statusCode});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized.', super.statusCode = 401});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.statusCode = 404});
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache read/write failed.', super.statusCode});
}

class LocationException extends AppException {
  const LocationException({required super.message, super.statusCode});
}

class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException({
    super.message = 'Location permission denied.',
  });
}

class LocationPermissionPermanentlyDeniedException extends AppException {
  const LocationPermissionPermanentlyDeniedException({
    super.message = 'Location permission permanently denied.',
  });
}

class InvalidInputException extends AppException {
  const InvalidInputException({required super.message});
}

class TooManyReportsException extends AppException {
  const TooManyReportsException({
    super.message = 'Report submitted too recently for this bus.',
  });
}
