import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/pmpml_api_constants.dart';
import '../constants/app_constants.dart';

/// Factory that creates pre-configured [Dio] instances for each Chartr service.
///
/// Each instance:
///  • Has the correct base URL
///  • Attaches the Bearer token from Hive on every request
///  • Handles 401 by clearing the stored tokens (no automatic re-login —
///    the UI listens to auth state and redirects the user)
///  • Retries transient failures up to [AppConstants.maxRetries] times
class PmpmlDioClient {
  PmpmlDioClient._();

  // ── Public factories ──────────────────────────────────────────────────────

  static Dio ticketing() => _create(PmpmlApiConstants.baseTicketing);
  static Dio routes() => _create(PmpmlApiConstants.baseRoutes);
  static Dio liveData() => _create(PmpmlApiConstants.baseLiveData);
  static Dio directions() => _create(PmpmlApiConstants.baseDirections);
  static Dio schedule() => _create(PmpmlApiConstants.baseSchedule);

  // ── Private builder ───────────────────────────────────────────────────────

  static Dio _create(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout:
            const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'platform': PmpmlApiConstants.platform,
          'app-version': PmpmlApiConstants.appVersion,
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_RetryInterceptor(dio));

    return dio;
  }
}

// ── Auth interceptor ──────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    final token = box.get(PmpmlApiConstants.keyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — clear stored tokens so auth provider notices
      final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
      box.delete(PmpmlApiConstants.keyAccessToken);
      box.delete(PmpmlApiConstants.keyRefreshToken);
    }
    handler.next(err);
  }
}

// ── Retry interceptor ─────────────────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  _RetryInterceptor(this._dio);

  static const _maxRetries = AppConstants.maxRetries;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final attempt =
        (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    final isRetriable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);

    if (isRetriable && attempt < _maxRetries) {
      final delaySecs = attempt == 0
          ? AppConstants.retryDelay1Secs
          : AppConstants.retryDelay2Secs;
      await Future<void>.delayed(Duration(seconds: delaySecs));

      final opts = err.requestOptions.copyWith(
        extra: {...err.requestOptions.extra, 'retryCount': attempt + 1},
      );
      try {
        final response = await _dio.fetch<dynamic>(opts);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }
    handler.next(err);
  }
}
