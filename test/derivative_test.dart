import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('derivative', () {
    test('D empty', () {
      expect(identical(empty, empty.derivative(23)), true);
    });

    test('D epsilon', () {
      expect(identical(eps().derivative(23), empty), true);
    });

    test('D token', () {
      expect(identical(token(23).derivative(42), empty), true);
      expect(token(23).derivative(23), isA<Epsilon>());
      expect(token(23).derivative(23).parseTrees(), equals({23}));
    });

    test('D union', () {
      var lang = token('a') | token('b');
      expect(lang.derivative('a'), epsToken('a'));
      expect(lang.derivative('b'), epsToken('b'));
      expect(lang.derivative('c'), empty);
    });

    test('D union smart eq', () {
      var lang = token('a') | token('b');
      expect(epsToken('a') | empty, lang.derivative('a'));
      expect(empty | epsToken('b'), lang.derivative('b'));
      expect(empty | empty, lang.derivative('c'));
    });

    test('D concat', () {
      var lang = token('a').seq(token('b'));
      //use compare the toString representations because projections
      //do not work with structural equality
      expect(
          (lang.derivative('a')).toString(),
          (token('a').delta.seq(token('b').derivative('a')) |
                  epsToken('a').seq(token('b')))
              .toString());
      lang = token('a').star.seq(token('b'));
      expect(
          lang.derivative('b').toString(),
          (token('a').star.delta.seq(token('b').derivative('b')) |
                  empty.seq(token('a')).seq(token('b')))
              .toString());
    });

    test('D delta', () {
      expect(identical(token('42').delta.derivative(23), empty), true);
    });

    test('D delayed xxx', () {
      expect((token(42).delayed(42).derivative(42) as Delayed).force(), empty);
    });
    test('D delayed a force', () {
      expect(Delayed(token('a'), 'a').force(), isA<Epsilon>());
      expect(Delayed(token('a'), 'b').force(), empty);
    });

    test('D delayed a∘b toString', () {
      var lang = token('a').concatenation(token('b'));
      expect((Delayed(lang, 'a').derivative('b') as Delayed).force().toString(),
          lang.derivative('a').derivative('b').toString());
    });

    test('D delayed a∘b equals', () {
      var lang = token('a').concatenation(token('b'));
      expect((lang.delayed('a').derivative('b') as Delayed).force(),
          lang.derivative('a').derivative('b'));
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
    });

    test('S = a | S =a=> ϵ | S', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      S.derivative('a');
      expect(S.derivative('a'), epsToken('a') | (token('a') | rS).delayed('a'));
    });

    test('S = a | S =a=> =a=>', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      expect(S.derivative('a').derivative('a'),
          (token('a') | rS).delayed('a').delayed('a'));
    });

    test('self loop', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.derivative('a'), rS.delayed('a'));
    });

    test('derivative of (delayed self loop) is itself', () {
      var rS = ref('S');

      rS.target = rS;
      var fixed = rS.delayed('a');
      var rsd = rS.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force(), fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force(), fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force(), fixed);
    });

    test('delay accumulates', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS.delayed('a');
      var rsd = rS.derivative('a');
      expect(rsd, fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed.derivative('a'));
      rsd = rsd.derivative('a');
      expect(rsd, fixed.delayed('a').delayed('a'));
    });

    test('force cleans accumulated delay', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS.delayed('a');
      var rsd = rS.derivative('a');
      rsd = rsd.derivative('a');
      rsd = rsd.derivative('a');
      expect((rsd as Delayed).force(), fixed);
    });

    test('different derivatives diff tokens', () {
      var rS = ref('S');
      var s = token('a') | token('b');
      rS.target = s;

      expect(s.derivative('a'), epsToken('a'));
      expect(s.derivative('b'), epsToken('b'));
      expect(s.derivative('c'), empty);

      expect((rS.derivative('a') as Delayed).force(), epsToken('a'));
      expect((rS.derivative('b') as Delayed).force(), epsToken('b'));
      expect((rS.derivative('c') as Delayed).force(), empty);
    });
  });
}
