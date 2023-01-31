import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/stupid_constructors.dart';
import 'package:test/test.dart';

void main() {
  group('derivative', () {
    test('D empty', () {
      expect(empty().derivative(23), empty());
    });

    test('D epsilon', () {
      expect(eps().derivative(23), empty());
    });

    test('D token', () {
      expect(token(23).derivative(42), empty());
      expect(token(23).derivative(23), eps());
    });

    test('D union', () {
      var lang = token('a') | token('b');
      expect(lang.derivative('a'), eps() | empty());
      expect(lang.derivative('b'), empty() | eps());
      expect(lang.derivative('c'), empty() | empty());
    });

    test('D union smart eq', () {
      var lang = token('a') | token('b');
      expect(eps() | empty(), lang.derivative('a'));
      expect(empty() | eps(), lang.derivative('b'));
      expect(empty() | empty(), lang.derivative('c'));
    });

    test('D concat', () {
      var lang = token('a').seq(token('b'));
      expect(
          (lang.derivative('a')),
          (token('a').delta.seq(token('b').derivative('a')) |
              eps().seq(token('b'))));
    });

    test('D delta', () {
      expect(token('42').delta.derivative(23), empty());
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

      var rT = ref('X');
      var X = eps() | rT;
      rT.target = X;
      expect(S.derivative('a'), X);
    });

    test('S = a | S =a=> =a=>', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      var rT = ref('X');
      var X = empty() | rT;
      rT.target = X;
      expect(S.derivative('a').derivative('a'), X);
    });

    test('self loop', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.derivative('a'), rS);
    });

    test('delay accumulates', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS;
      var rsd = rS.derivative('a');
      expect(rsd, fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed.derivative('a'));
      rsd = rsd.derivative('a');
      expect(rsd, fixed.derivative('a').derivative('a'));
    });

    test('force accumulated delay', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS;
      var rsd = rS.derivative('a');
      rsd = rsd.derivative('a');
      rsd = rsd.derivative('a');
      expect(rsd, fixed);
    });

    test('different derivatives diff tokens', () {
      var rS = ref('S');
      var s = token('a') | token('b');
      rS.target = s;

      expect(s.derivative('a'), eps() | empty());
      expect(s.derivative('b'), empty() | eps());
      expect(s.derivative('c'), empty() | empty());
    });

    test('different derivatives diff tokens', () {
      var s = token('c').seq(token('a') | token('b'));
      var t1 = (token('c').delta.delta.seq(empty() | empty()) |
              (empty().seq(empty() | empty()))) |
          ((eps().delta.seq(eps() | empty())) |
              (empty().seq(token('a') | token('b'))));
      var t2 = (token('c').delta.delta.seq(empty() | empty()) |
              (empty().seq(empty() | empty()))) |
          ((eps().delta.seq(empty() | eps())) |
              (empty().seq(token('a') | token('b'))));
      var t3 = (token('c').delta.delta.seq(empty() | empty()) |
              (empty().seq(empty() | empty()))) |
          ((eps().delta.seq(empty() | empty())) |
              (empty().seq(token('a') | token('b'))));
      //no delay
      expect(s.derivative('c').derivative('a'), t1);
      expect(s.derivative('c').derivative('b'), t2);
      expect(s.derivative('c').derivative('c'), t3);
    });
  });
}
