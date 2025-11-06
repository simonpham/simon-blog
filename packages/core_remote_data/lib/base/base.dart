import 'dart:async';

import 'package:core/core.dart';

abstract interface class BaseRepository<T> {
  const BaseRepository();

  FutureOr<Failure?> add(T item);

  FutureOr<Failure?> addAll(List<T> items);

  FutureOr<Failure?> update(T item);

  FutureOr<T?> get(String id);

  FutureOr<List<T>> list(
    Pagination pagination, {
    String? searchQuery,
  });

  FutureOr<Failure?> delete(String id);

  FutureOr<int> count();
}
