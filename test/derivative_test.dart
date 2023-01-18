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
    test('D delta', () {
      expect(identical(token('42').delta().derive(23), empty), true);
    });

    test('D delayed', () {
      expect(Delayed(token(42), 42).derive(42), empty);
    });
    test('D delayed a force', () {
      expect(Delayed(token('a'), 'a').force(), isA<Epsilon>());
      expect(Delayed(token('a'), 'b').force(), empty);
    });

    test('D delayed a∘b toString', () {
      var lang = token('a').concatenation(token('b'));
      expect(Delayed(lang, 'a').derive('b').toString(),
          lang.derive('a').derive('b').toString());
    });

    test('D delayed a∘b equals', () {
      var lang = token('a').concatenation(token('b'));
      expect(Delayed(lang, 'a').derive('b'), lang.derive('a').derive('b'));
    });
  });
}
