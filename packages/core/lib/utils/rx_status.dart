import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';

@immutable
class RxStatus<T> {
  final bool isLoading;
  final T? data;
  final String? error;

  const RxStatus({
    this.isLoading = false,
    this.data,
    this.error,
  });

  factory RxStatus.loading() {
    return const RxStatus(isLoading: true);
  }

  factory RxStatus.error(String error) {
    return RxStatus(error: error);
  }

  factory RxStatus.data(T data) {
    return RxStatus(data: data);
  }

  RxStatus<T> copyWith({
    bool? isLoading,
    Some<T?>? data,
    Some<String?>? error,
  }) {
    return RxStatus<T>(
      isLoading: isLoading ?? this.isLoading,
      data: data != null ? data.value : this.data,
      error: error != null ? error.value : this.error,
    );
  }
}
