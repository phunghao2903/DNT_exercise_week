import 'package:chat_ui_clone/core/exceptions.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    }
    return failure((this as Failure<T>).error);
  }
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}
