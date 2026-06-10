import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Singleton Dio client with Auth, Logging, Retry and Cache interceptors.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _log(obj.toString()),
      ),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;

  void _log(String message) {
    // ignore: avoid_print
    assert(() {
      // ignore: avoid_print
      print('[DioClient] $message');
      return true;
    }());
  }
}

// ─── Auth Interceptor ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Firebase Auth token injected lazily to avoid circular imports.
      // Import firebase_auth only here to keep DioClient loosely coupled.
      // ignore: invalid_annotation_target
      final token = await _getFirebaseToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Proceed without token if fetch fails.
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt one token refresh then retry.
      try {
        final newToken = await _refreshFirebaseToken();
        if (newToken != null) {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final clonedResp = await Dio().fetch(opts);
          return handler.resolve(clonedResp);
        }
      } catch (_) {}
    }
    handler.next(err);
  }

  Future<String?> _getFirebaseToken() async {
    try {
      // Lazy import to avoid coupling at top level.
      // In real app: firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken()
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _refreshFirebaseToken() async {
    try {
      return null; // Replace with: currentUser?.getIdToken(true)
    } catch (_) {
      return null;
    }
  }
}

// ─── Retry Interceptor ────────────────────────────────────────────────────────
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = AppConstants.maxRetries;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isRetryable && retryCount < _maxRetries) {
      final delay = retryCount == 0
          ? AppConstants.retryDelay1Secs
          : AppConstants.retryDelay2Secs;
      await Future.delayed(Duration(seconds: delay));

      err.requestOptions.extra['retryCount'] = retryCount + 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
      }
    }
    handler.next(err);
  }
}
