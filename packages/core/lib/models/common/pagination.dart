abstract base class Pagination {
  const Pagination();

  Pagination nextPage();
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

  @override
  Pagination nextPage() {
    return OffsetLimitPagination(offset: offset + limit, limit: limit);
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

  @override
  Pagination nextPage() {
    return PagePagination(page: page + 1, pageSize: pageSize);
  }
}
