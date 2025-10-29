abstract class AppException implements Exception {
  AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  NetworkException(String message, {Object? cause})
      : super(message, cause: cause);
}

class ApiException extends AppException {
  ApiException(String message, {Object? cause})
      : super(message, cause: cause);
}

class ParsingException extends AppException {
  ParsingException(String message, {Object? cause})
      : super(message, cause: cause);
}
