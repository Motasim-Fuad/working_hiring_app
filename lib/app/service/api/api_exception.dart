/// Exception thrown when the backend returns {"status": false, "message": "..."}
class ApiException implements Exception {
  final String message;
  final dynamic data;
  const ApiException(this.message, [this.data]);

  @override
  String toString() => message;
}
