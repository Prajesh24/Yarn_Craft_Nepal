import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Use case that takes parameters — matches your Stockex pattern.
abstract interface class UseCaseWithParams<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that needs no parameters.
abstract interface class UseCaseWithoutParams<Type> {
  Future<Either<Failure, Type>> call();
}
