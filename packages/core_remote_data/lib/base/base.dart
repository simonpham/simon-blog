import 'dart:async';

import 'package:core/core.dart';

abstract interface class BaseRepository<T> {
  const BaseRepository();

  FutureOr<T> add(T item);

  FutureOr<List<T>> addAll(List<T> items);

  FutureOr<T> update(T item);

  FutureOr<T?> get(String id);

  FutureOr<List<T>> list(
    Pagination pagination, {
    String? searchQuery,
  });

  FutureOr<void> delete(String id);

  FutureOr<int> count();
}
