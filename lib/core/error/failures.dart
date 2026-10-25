import 'package:equatable/equatable.dart';

/// Base failure returned on the Left side of `Either<Failure, T>`.
///
/// Sealed so `switch (failure)` is checked for exhaustiveness. All subclasses
/// must live in this file. Add a feature-specific subclass here for each new
/// feature.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

class RecipeFailure extends Failure {
  const RecipeFailure(super.message);
}
