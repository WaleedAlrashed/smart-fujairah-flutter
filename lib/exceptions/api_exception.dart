sealed class ApiException implements Exception {
  final String messageEn;
  final String messageAr;
  final int? statusCode;

  const ApiException({
    required this.messageEn,
    required this.messageAr,
    this.statusCode,
  });

  String message(String locale) => locale == 'ar' ? messageAr : messageEn;
}

class NetworkException extends ApiException {
  const NetworkException()
      : super(
          messageEn: 'No internet connection. Please check your network.',
          messageAr: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
        );
}

class TimeoutException extends ApiException {
  const TimeoutException()
      : super(
          messageEn: 'Request timed out. Please try again.',
          messageAr: 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.',
        );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException()
      : super(
          messageEn: 'Session expired. Please login again.',
          messageAr: 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
          statusCode: 401,
        );
}

class ServerException extends ApiException {
  const ServerException({String? detail})
      : super(
          messageEn: detail ?? 'Server error. Please try again later.',
          messageAr: 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
          statusCode: 500,
        );
}

class NotFoundException extends ApiException {
  const NotFoundException()
      : super(
          messageEn: 'The requested resource was not found.',
          messageAr: 'لم يتم العثور على المورد المطلوب.',
          statusCode: 404,
        );
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  const ValidationException({this.errors})
      : super(
          messageEn: 'Please check your input.',
          messageAr: 'يرجى التحقق من المدخلات.',
          statusCode: 422,
        );
}
