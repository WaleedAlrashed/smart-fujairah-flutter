import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../exceptions/api_exception.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../models/announcement.dart';
import '../models/service_request.dart';
import '../models/plot.dart';
import '../models/user.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  String? get authToken => _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));

    // Error interceptor — maps Dio errors to typed ApiExceptions
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          final ApiException apiException;

          switch (error.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              apiException = const TimeoutException();
            case DioExceptionType.connectionError:
              apiException = const NetworkException();
            case DioExceptionType.badResponse:
              final statusCode = error.response?.statusCode;
              apiException = switch (statusCode) {
                401 => const UnauthorizedException(),
                404 => const NotFoundException(),
                422 => ValidationException(
                    errors: error.response?.data is Map
                        ? error.response?.data as Map<String, dynamic>
                        : null),
                _ => ServerException(
                    detail: error.response?.data is Map
                        ? (error.response?.data
                            as Map<String, dynamic>)['message'] as String?
                        : null),
              };
            default:
              apiException = const ServerException();
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  Future<List<ServiceCategory>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    return (response.data as List)
        .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MunicipalityService>> getCategoryServices(int categoryId) async {
    final response = await _dio.get(ApiConstants.categoryServices(categoryId));
    return (response.data as List)
        .map((e) => MunicipalityService.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MunicipalityService> getServiceDetail(int serviceId) async {
    final response = await _dio.get(ApiConstants.serviceDetail(serviceId));
    return MunicipalityService.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MunicipalityService>> searchServices(String query) async {
    final response = await _dio.get(ApiConstants.searchServices(query));
    return (response.data as List)
        .map((e) => MunicipalityService.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Plot>> getPlots() async {
    final response = await _dio.get(ApiConstants.plots);
    return (response.data as List)
        .map((e) => Plot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _dio.get(ApiConstants.announcements);
    return (response.data as List)
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> submitRequest({
    required int serviceId,
    required String fullName,
    required String emiratesId,
    required String phone,
    required String email,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiConstants.requests,
      data: {
        'service_id': serviceId,
        'full_name': fullName,
        'emirates_id': emiratesId,
        'phone': phone,
        'email': email,
        'notes': notes,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _dio.post(ApiConstants.upload, data: formData);
    return response.data as Map<String, dynamic>;
  }

  Future<List<ServiceRequest>> getMyRequests() async {
    final response = await _dio.get(ApiConstants.myRequests);
    return (response.data as List)
        .map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Auth methods ──────────────────────────────────────────────────────

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Map<String, dynamic>> login({
    required String emiratesId,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'emirates_id': emiratesId, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String nameEn,
    required String nameAr,
    required String emiratesId,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: {
        'name_en': nameEn,
        'name_ar': nameAr,
        'emirates_id': emiratesId,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<AppUser> getMe() async {
    final response = await _dio.get('/api/auth/me');
    return AppUser.fromJson(
      (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }
}
