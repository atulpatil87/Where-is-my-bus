import 'package:dio/dio.dart';
import '../../../../core/constants/pmpml_api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/pmpml/pmpml_direction_model.dart';

class PmpmlDirectionsDataSource {
  final Dio _dio;

  PmpmlDirectionsDataSource(this._dio);

  Future<PmpmlDirectionModel> getBusDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        PmpmlApiConstants.directionsBusV2,
        data: {
          'from_lat': fromLat,
          'from_lng': fromLng,
          'to_lat': toLat,
          'to_lng': toLng,
          'city': PmpmlApiConstants.city,
        },
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty directions response.');
      }

      // Some endpoints wrap in a 'data' key
      final payload = response.data is Map &&
              (response.data as Map).containsKey('data')
          ? (response.data as Map)['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      return PmpmlDirectionModel.fromJson(payload);
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
          throw const NotFoundException(message: 'No route found for this journey.');
        }
        throw ServerException(
          message: e.response?.data?.toString() ?? e.message ?? 'Directions API error.',
          statusCode: status,
        );
    }
  }
}
