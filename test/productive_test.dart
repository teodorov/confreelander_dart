import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('productivity', () {
    test('empty.isProductive', () {
      expect(empty.isProductive, false);
    });

    test('ϵ.isProductive', () {
      expect(eps().isProductive, true);
      expect(epsToken(2).isProductive, true);
      expect(epsTrees({2}).isProductive, true);
    });
    test('token.isProductive', () {
      expect(token(42).isProductive, true);
    });
    test('t[42] | t[32] . isProductive', () {
      var l = token(42) | token(43);
      expect(l.isProductive, true);
    });
    test('t[42] | eps . isProductive', () {
      var l = token(42) | eps();
      expect(l.isProductive, true);
    });

    test('t[42] | eps | t[3] . isProductive', () {
      var l = token(42) | eps() | token(3);
      expect(l.isProductive, true);
    });

    test('t[42] ∘ t[3] . isProductive', () {
      var l = token(42).seq(token(3));
      expect(l.isProductive, true);
    });

    test('t[42] ∘ eps . isProductive', () {
      var l = token(42).seq(eps());
      expect(l.isProductive, true);
    });

    test('eps ∘ t[4] . isProductive', () {
      var l = eps().seq(token(3));
      expect(l.isProductive, true);
    });
    test('eps ∘ eps . isProductive', () {
      var l = eps().seq(eps());
      expect(l.isProductive, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ϵ)', () {
      var l = (eps() | token(3)).seq(empty | eps());
      expect(l.isProductive, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)', () {
      var l = (eps() | token(3)).seq(empty | empty);
      expect(l.isProductive, false);
    });
    test('t(3).star.isProductive', () {
      var l = token(3).star;
      expect(l.isProductive, true);
    });

    test('∅* .isProductive', () {
      var l = empty.star;
      expect(l.isProductive, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)* .isProductive', () {
      var l = (eps() | token(3)).seq((empty | empty).star);
      expect(l.isProductive, true);
    });

    test('delta ∅ .isProductive', () {
      var l = empty.delta;
      expect(l.isProductive, false);
    });

    test('delta eps .isProductive', () {
      var l = eps().delta;
      expect(l.isProductive, true);
    });

    test('delta token(2) .isProductive', () {
      var l = token(2).delta;
      expect(l.isProductive, true);
    });

    test('∅ >> f .isProductive', () {
      var l = empty >> (v) => print(v);
      expect(l.isProductive, false);
    });

    test('ϵ >> f .isProductive', () {
      var l = eps() >> (v) => v;
      expect(l.isProductive, true);
    });

    test('tok(3) >> f .isProductive', () {
      var l = token(3) >> (v) => print(v);
      expect(l.isProductive, true);
    });

    test('∅.delayed(2) .isProductive', () {
      var l = empty.delayed(2);
      expect(l.isProductive, false);
    });

    test('ϵ.delayed(2) .isProductive', () {
      var l = eps().delayed(2);
      expect(l.isProductive, false);
    });

    test('tok(3).delayed(2) .isProductive', () {
      var l = token(3).delayed(2);
      expect(l.isProductive, false);
    });

    test('tok(3).delayed(3) .isProductive', () {
      var l = token(3).delayed(3);
      expect(l.isProductive, true);
    });

    test('tok(3).delayed(3).delayed(3) .isProductive', () {
      var l = token(3).delayed(3).delayed(3);
      expect(l.isProductive, false);
    });

    test('S = tok(a) | S .isProductive', () {
      var rS = ref('S');
      var l = token('a') | rS;
      rS.target = l;

      expect(l.isProductive, true);
    });

    test('S = ϵ | S .isProductive', () {
      var rS = ref('S');
      var l = eps() | rS;
      rS.target = l;

      expect(l.isProductive, true);
    });

    test('S = tok(a) | S rS.isProductive', () {
      var rS = ref('S');
      var l = token('a') | rS;
      rS.target = l;

      expect(rS.isProductive, true);
    });

    test('S = ϵ | S rS.isProductive', () {
      var rS = ref('S');
      var l = eps() | rS;
      rS.target = l;

      expect(rS.isProductive, true);
    });

    test('S = S | ϵ rS.isProductive', () {
      var rS = ref('S');
      var l = rS | eps();
      rS.target = l;

      expect(rS.isProductive, true);
    });

    test('S = S* .isProductive', () {
      var rS = ref('S');
      var l = rS.star;
      rS.target = l;

      expect(l.isProductive, true);
    });

    test('S = S* rS.isProductive', () {
      var rS = ref('S');
      var l = rS.star;
      rS.target = l;

      expect(rS.isProductive, true);
    });

    test('self loop not nullable', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.isProductive, false);
    });

    test('derive self loop not nullable', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.derivative('a').isProductive, false);
    });

    test('two refs isProductive', () {
      var rA = ref('A');
      var l = rA | token('x');
      rA.target = l;
      var l1 = ref('B');
      l1.target = rA;

      expect(rA.isProductive, true);
      expect(l.isProductive, true);
      expect(l1.isProductive, true);
    });

    test('two refs isProductive', () {
      var rA = ref('A');
      var l = rA | token('x');
      rA.target = l;
      var l1 = rA;

      expect(rA.isProductive, true);
      expect(l.isProductive, true);
      expect(l1.isProductive, true);
    });
  });
}
