sealed class AppResult<T> {
  const AppResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? cause) failure,
  }) {
    final value = this;
    if (value is AppSuccess<T>) {
      return success(value.data);
    }
    final error = value as AppFailure<T>;
    return failure(error.message, error.cause);
  }
}

class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);

  final T data;
}

class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}
