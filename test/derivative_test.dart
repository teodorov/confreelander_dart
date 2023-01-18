import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('derivative', () {
    test('D empty', () {
      expect(identical(empty, empty.derive(23)), true);
    });

    test('D epsilon', () {
      expect(identical(eps().derive(23), empty), true);
    });

    test('D token', () {
      expect(identical(token(23).derive(42), empty), true);
      expect(token(23).derive(23), isA<Epsilon>());
      expect(token(23).derive(23).parseTrees(), equals({23}));
    });
  });
}
