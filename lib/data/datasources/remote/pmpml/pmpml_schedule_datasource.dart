import 'package:dio/dio.dart';
import '../../../../core/constants/pmpml_api_constants.dart';
import '../../../../core/errors/exceptions.dart';

class PmpmlScheduleDataSource {
  final Dio _dio;

  PmpmlScheduleDataSource(this._dio);

  /// Returns raw schedule map for [routeNumber] in Pune.
  Future<Map<String, dynamic>> getRouteSchedule(String routeNumber) async {
    try {
      final response = await _dio.get<dynamic>(
        PmpmlApiConstants.schedule(routeNumber),
      );
      if (response.data == null) {
        throw NotFoundException(message: 'No schedule for route $routeNumber.');
      }
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'raw': response.data};
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Returns schedule for [routeNumber] at a specific [stopId].
  Future<Map<String, dynamic>> getScheduleAtStop(
      String routeNumber, String stopId) async {
    try {
      final response = await _dio.get<dynamic>(
        PmpmlApiConstants.scheduleAtStop(routeNumber, stopId),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'raw': response.data};
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

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
          throw const NotFoundException(message: 'Schedule not found.');
        }
        throw ServerException(
          message: e.response?.data?.toString() ?? e.message ?? 'Schedule API error.',
          statusCode: status,
        );
    }
  }
}
