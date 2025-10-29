class ProductNotFoundException implements Exception {
  final String message;
  ProductNotFoundException([this.message = "Product not found"]);

  @override
  String toString() => "ProductNotFoundException: $message";
}

class UnauthorizedOperationException implements Exception {
  final String message;
  UnauthorizedOperationException([this.message = "Operation not allowed"]);

  @override
  String toString() => "UnauthorizedOperationException: $message";
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException([this.message = "Repository error"]);

  @override
  String toString() => "RepositoryException: $message";
}

class SnapshotNotFoundException implements Exception {
  final String message;
  SnapshotNotFoundException([this.message = "No snapshot found"]);

  @override
  String toString() => "SnapshotNotFoundException: $message";
}

class DatabaseConnectionException implements Exception {
  final String message;
  DatabaseConnectionException([this.message = "Could not connect to server"]);

  @override
  String toString() => "DatabaseConnectionException: $message";
}

class RoomCreationException implements Exception {
  final String message;
  RoomCreationException([this.message = "Failed to create room"]);
  @override
  String toString() => message;
}

class RoomHttpException extends RoomCreationException {
  final int statusCode;
  RoomHttpException(this.statusCode, [String message = "HTTP error"])
      : super("HTTP error $statusCode: $message");
}

class RoomDecodingException extends RoomCreationException {
  RoomDecodingException([super.message = "Failed to decode room data"]);
}

class ObjectException implements Exception {
  final String message;
  ObjectException([this.message = "Failed to translate JSON"]);

  @override
  String toString() => "ObjectException: $message";
}
