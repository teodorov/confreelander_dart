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

    test('D union', () {
      var lang = token('a') | token('b');
      expect(lang.derive('a'), Union(epsToken('a'), empty));
      expect(lang.derive('b'), Union(empty, epsToken('b')));
      expect(lang.derive('c'), Union(empty, empty));
    });

    test('D union smart eq', () {
      var lang = token('a') | token('b');
      expect(epsToken('a') | empty, lang.derive('a'));
      expect(empty | epsToken('b'), lang.derive('b'));
      expect(empty | empty, lang.derive('c'));
    });

    test('D concat', () {
      var lang = token('a').seq(token('b'));
      expect(
          token('a').delta.seq(token('b').derive('a')) |
              epsToken('a').seq(token('b')),
          lang.derive('a'));
      lang = token('a').star.seq(token('b'));
      expect(
        token('a').star.delta.seq(token('b').derive('b')) |
            empty.seq(token('a')).seq(token('b')),
        lang.derive('b'),
      );
    });

    test('D delta', () {
      expect(identical(token('42').delta.derive(23), empty), true);
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
