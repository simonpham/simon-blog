abstract base class Pagination {
  const Pagination();
}

final class OffsetLimitPagination extends Pagination {
  final int offset;
  final int limit;

  const OffsetLimitPagination({
    required this.offset,
    required this.limit,
  });

  factory OffsetLimitPagination.initial() {
    return const OffsetLimitPagination(offset: 0, limit: 10);
  }
}

final class PagePagination extends Pagination {
  final int page;
  final int pageSize;

  const PagePagination({
    required this.page,
    required this.pageSize,
  });

  factory PagePagination.initial() {
    return const PagePagination(page: 1, pageSize: 10);
  }
}
