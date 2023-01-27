import 'package:confreelander/src/stupid_constructors.dart';
import 'package:confreelander/src/stupid_languages.dart';
import 'package:test/test.dart';

void main() {
  group('derivative', () {
    test('D empty', () {
      expect(identical(empty, empty().derivative(23)), true);
    });

    test('D epsilon', () {
      expect(identical(eps().derivative(23), empty()), true);
    });

    test('D token', () {
      expect(identical(token(23).derivative(42), empty()), true);
      expect(token(23).derivative(23), isA<Epsilon>());
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
      expect(identical(token('42').delta.derivative(23), empty()), true);
    });

    test('D delayed xxx', () {
      expect(token(42).delayed().derivative(42), eps().delayed());
    });
    test('D delayed a force', () {
      expect(
          Delayed(
            token('a'),
          ).force('a'),
          isA<Epsilon>());
      expect(
          Delayed(
            token('a'),
          ).force('b'),
          empty());
    });

    test('D delayed a∘b toString', () {
      var lang = token('a').concatenation(token('b'));
      expect((lang.delayed().derivative('b') as Delayed).force('a').toString(),
          lang.derivative('a').derivative('b').toString());
    });

    test('D delayed a∘b equals', () {
      var lang = token('a').concatenation(token('b'));
      expect((lang.delayed().derivative('b') as Delayed).force('a'),
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
      expect(S.derivative('a'), eps() | (token('a') | rS).delayed());
    });

    test('S = a | S =a=> =a=>', () {
      var rS = ref('S');
      var S = token('a') | rS;
      rS.target = S;

      expect(S.derivative('a').derivative('a'),
          empty() | (eps() | (token('a') | rS).delayed()).delayed());
    });

    test('self loop', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.derivative('a'), rS.delayed());
    });

    test('derivative of (delayed self loop) is itself', () {
      var rS = ref('S');

      rS.target = rS;
      var fixed = rS.delayed();
      var rsd = rS.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force('a'), fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force('a'), fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed);
      expect((rsd as Delayed).force('a'), fixed);
    });

    test('delay accumulates', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS.delayed();
      var rsd = rS.derivative('a');
      expect(rsd, fixed);
      rsd = rsd.derivative('a');
      expect(rsd, fixed.derivative('a'));
      rsd = rsd.derivative('a');
      expect(rsd, fixed.delayed().delayed());
    });

    test('force accumulated delay', () {
      var rS = ref('S');
      rS.target = rS;
      var fixed = rS.delayed().delayed().delayed();
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

      expect((rS.derivative('a') as Delayed).force('a'), eps() | empty());
      expect((rS.derivative('b') as Delayed).force('b'), empty() | eps());
      expect((rS.derivative('c') as Delayed).force('c'), empty() | empty());
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
      //different delay
      expect((s.delayed().derivative('a') as Delayed).force('a'), t1);
      expect((s.delayed().derivative('b') as Delayed).force('b'), t2);
      expect((s.delayed().derivative('c') as Delayed).force('c'), t3);

      //reuse delay
      // ignore: non_constant_identifier_names
      var delayed_c = s.delayed();
      expect((delayed_c.derivative('a') as Delayed).force('a'), t1);
      expect((delayed_c.derivative('b') as Delayed).force('b'), t2);
      expect((delayed_c.derivative('c') as Delayed).force('c'), t3);
    });

    test('different derivatives diff tokens 3', () {
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
      //reuse delay
      // ignore: non_constant_identifier_names
      var delayed_c = s.delayed();
      expect((delayed_c.derivative('a') as Delayed).force('a'), t1);
      expect((delayed_c.derivative('b') as Delayed).force('b'), t2);
      expect((delayed_c.derivative('c') as Delayed).force('c'), t3);
    });
  });
}
