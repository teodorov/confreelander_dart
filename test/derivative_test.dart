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
      expect(lang.derive('a'), epsToken('a'));
      expect(lang.derive('b'), epsToken('b'));
      expect(lang.derive('c'), empty);
    });

    test('D union smart eq', () {
      var lang = token('a') | token('b');
      expect(epsToken('a') | empty, lang.derive('a'));
      expect(empty | epsToken('b'), lang.derive('b'));
      expect(empty | empty, lang.derive('c'));
    });

    test('D concat', () {
      var lang = token('a').seq(token('b'));
      //use compare the toString representations because projections
      //do not work with structural equality
      expect(
          (lang.derive('a')).toString(),
          (token('a').delta.seq(token('b').derive('a')) |
                  epsToken('a').seq(token('b')))
              .toString());
      lang = token('a').star.seq(token('b'));
      expect(
          lang.derive('b').toString(),
          (token('a').star.delta.seq(token('b').derive('b')) |
                  empty.seq(token('a')).seq(token('b')))
              .toString());
    });

    test('D delta', () {
      expect(identical(token('42').delta.derive(23), empty), true);
    });

    test('D delayed xxx', () {
      expect((token(42).delayed(42).derive(42) as Delayed).force(), empty);
    });
    test('D delayed a force', () {
      expect(Delayed(token('a'), 'a').force(), isA<Epsilon>());
      expect(Delayed(token('a'), 'b').force(), empty);
    });

    test('D delayed a∘b toString', () {
      var lang = token('a').concatenation(token('b'));
      expect((Delayed(lang, 'a').derive('b') as Delayed).force().toString(),
          lang.derive('a').derive('b').toString());
    });

    test('D delayed a∘b equals', () {
      var lang = token('a').concatenation(token('b'));
      expect((lang.delayed('a').derive('b') as Delayed).force(), lang.derive('a').derive('b'));
    });

    test('ref', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      var rS1 = ref('S');
      // ignore: non_constant_identifier_names
      var S1 = token('a') | rS1;
      rS1.target = S1;

      expect(rS.hashCode == rS1.hashCode, true);
      expect(S.hashCode == S1.hashCode, true);

      //expect(S.derive('a'), epsToken('a') | S);
    });

    test('S = a | S =a=> ϵ | S', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      S.derive('a');
      expect(S.derive('a'), epsToken('a') | (token('a') | rS).delayed('a'));
      // expect(S.derive('a').derive('a'),
      //     epsToken('a') | (token('a') | rS).delayed('a'));
    });

    test('S = a | S =a=> =a=>', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      expect(S.derive('a').derive('a'),
          (token('a') | rS).delayed('a').delayed('a'));
    });
  });
}
