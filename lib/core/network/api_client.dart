import 'dart:io';

import 'package:dio/dio.dart';
import 'package:navex/core/utils/app_preference.dart';
import '../config/api_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseApiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'API-Version': ApiConfig.apiVersion,
        },
      ),
    );

    // ✅ Auth Token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppPreference.getString(AppPreference.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // ✅ Logging interceptor
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  /// 🔑 Set or update bearer token dynamically
  void setAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  /// 🧾 Generic GET request
  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 📨 Generic POST request (supports normal & multipart)
  Future<Response> postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    File? file,
    String? fileField = 'file',
  }) async {
    try {
      FormData? formData;

      if (file != null) {
        formData = FormData.fromMap({
          ...?data,
          fileField!: await MultipartFile.fromFile(file.path),
        });
      }

      final response = await dio.post(
        endpoint,
        data: formData ?? data,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✏️ Generic PUT request (supports multipart)
  Future<Response> putRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    File? file,
    String? fileField = 'file',
  }) async {
    try {
      FormData? formData;

      if (file != null) {
        formData = FormData.fromMap({
          ...?data,
          fileField!: await MultipartFile.fromFile(file.path),
        });
      }

      final response = await dio.put(
        endpoint,
        data: formData ?? data,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ❌ Generic DELETE request
  Future<Response> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ⚠️ Centralized error handling
  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ??
          e.response?.statusMessage ??
          'Unknown server error';
    } else {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout';
        case DioExceptionType.badResponse:
          return 'Invalid response from server';
        case DioExceptionType.connectionError:
          return 'No internet connection';
        default:
          return 'Unexpected error';
      }
    }
  }
}
