sealed class UiState<T> {
  const UiState();
}

class UiIdle<T> extends UiState<T> {
  const UiIdle();
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

class UiData<T> extends UiState<T> {
  const UiData(this.value);

  final T value;
}

class UiEmpty<T> extends UiState<T> {
  const UiEmpty(this.message);

  final String message;
}

class UiFailure<T> extends UiState<T> {
  const UiFailure(this.message);

  final String message;
}
