import 'package:test/test.dart';

import 'package:utils/utils.dart' hide equals;

const _exampleParagraph = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
''';

void main() {
  group('WordCountUtils', () {
    test('countWords', () {
      expect(WordCountUtils.countWords(_exampleParagraph), equals(69));
    });

    test('calculateReadingTime', () {
      expect(
        WordCountUtils.calculateReadingTime(_exampleParagraph),
        equals(const Duration(seconds: 16)),
      );
    });
  });
}
