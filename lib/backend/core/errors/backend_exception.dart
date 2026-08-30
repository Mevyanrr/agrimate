/// Error terkontrol yang boleh diteruskan dari backend ke presentation layer.
class BackendException implements Exception {
  const BackendException(this.message, {this.code, this.originalError});

  final String message;
  final String? code;
  final Object? originalError;

  @override
  String toString() => 'BackendException($code): $message';
}

