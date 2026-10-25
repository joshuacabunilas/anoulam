/// Thrown by data sources; caught by repository impls and mapped to a [Failure].
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class CacheException implements Exception {
  const CacheException(this.message);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}
