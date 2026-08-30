/// Membuat UI menangani sukses/gagal tanpa bergantung pada exception Supabase.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;
}

