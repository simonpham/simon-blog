import 'package:core/models/models.dart';
import 'package:core_remote_data/core_remote_data.dart';
import 'package:core_remote_data_pb/core_remote_data_pb.dart'
    show NowisPostApis;
import 'package:test/test.dart';

void main() {
  final PostApis nowisPostApis = NowisPostApis(
    host: 'api.nowis.sofluffy.io',
  );

  group('NowisPostApis', () {
    test('get list ', () async {
      final result = await nowisPostApis.list(
        PagePagination.initial(),
      );

      expect(result, isA<List<Post>>());
      expect(result.length, greaterThan(0));
    });
  });
}
