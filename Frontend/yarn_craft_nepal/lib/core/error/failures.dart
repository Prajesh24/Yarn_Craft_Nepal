abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when the remote server returns an error.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Thrown when a local Hive operation fails.
class LocalDatabaseFailue extends Failure {
  const LocalDatabaseFailue({required super.message});
}

/// Thrown when there is no internet connection and no local fallback.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}
