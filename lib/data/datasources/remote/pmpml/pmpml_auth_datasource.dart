import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/pmpml_api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/pmpml/pmpml_auth_model.dart';

/// Handles OTP-based login against the PMPML / Chartr ticketing backend.
///
/// Tokens are persisted in the `user_prefs` Hive box so [PmpmlDioClient]
/// can attach them to every subsequent request automatically.
class PmpmlAuthDataSource {
  final Dio _dio;

  PmpmlAuthDataSource(this._dio);

  // ── Send OTP ──────────────────────────────────────────────────────────────

  /// Sends an OTP to [mobile]. Returns `true` on success.
  Future<bool> sendOtp(String mobile) async {
    try {
      final response = await _dio.post<dynamic>(
        PmpmlApiConstants.sendOtp(mobile),
        data: {
          'mobile': mobile,
          'platform': PmpmlApiConstants.platform,
        },
      );
      // 200 / 201 both indicate OTP was sent
      return (response.statusCode ?? 0) < 300;
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return false;
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────

  /// Verifies [otp] for [mobile]. On success, persists tokens to Hive
  /// and returns a [PmpmlAuthModel].
  Future<PmpmlAuthModel> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        PmpmlApiConstants.verifyOtp(mobile),
        data: {
          'mobile': mobile,
          'otp': otp,
        },
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from OTP verify.');
      }

      final auth = PmpmlAuthModel.fromJson(response.data!);
      if (!auth.isValid) {
        throw const ServerException(
            message: 'Invalid token in OTP verify response.');
      }

      await _persistTokens(auth);
      return auth;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ── Token Helpers ─────────────────────────────────────────────────────────

  Future<void> _persistTokens(PmpmlAuthModel auth) async {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    await box.put(PmpmlApiConstants.keyAccessToken, auth.accessToken);
    await box.put(PmpmlApiConstants.keyRefreshToken, auth.refreshToken);
    await box.put(PmpmlApiConstants.keyMobile, auth.mobile);
    if (auth.userId != null) {
      await box.put(PmpmlApiConstants.keyUserId, auth.userId!);
    }
  }

  /// Returns the stored access token, or null if not logged in.
  String? getStoredToken() {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    return box.get(PmpmlApiConstants.keyAccessToken);
  }

  /// Returns the stored mobile number, or null.
  String? getStoredMobile() {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    return box.get(PmpmlApiConstants.keyMobile);
  }

  /// Clears all PMPML tokens from Hive (logout).
  Future<void> clearTokens() async {
    final box = Hive.box<String>(PmpmlApiConstants.hiveBoxUserPrefs);
    await box.delete(PmpmlApiConstants.keyAccessToken);
    await box.delete(PmpmlApiConstants.keyRefreshToken);
    await box.delete(PmpmlApiConstants.keyMobile);
    await box.delete(PmpmlApiConstants.keyUserId);
  }

  bool get isAuthenticated {
    final token = getStoredToken();
    return token != null && token.isNotEmpty;
  }

  // ── Error Handling ────────────────────────────────────────────────────────

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const TimeoutException();
      case DioExceptionType.connectionError:
        throw const NetworkException();
      default:
        final status = e.response?.statusCode;
        if (status == 401) throw const UnauthorizedException();
        if (status == 404) {
          throw const NotFoundException(message: 'API endpoint not found (404). Please verify API constants.');
        }
        
        final errorData = e.response?.data?.toString() ?? '';
        final isHtml = errorData.trim().startsWith('<');
        throw ServerException(
          message: isHtml ? 'Server returned an invalid response ($status)' : (errorData.isNotEmpty ? errorData : e.message ?? 'PMPML auth error.'),
          statusCode: status,
        );
    }
  }
}
