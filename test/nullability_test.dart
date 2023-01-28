import 'package:confreelander/confreelander.dart';
import 'package:confreelander/src/stupid_constructors.dart';
import 'package:test/test.dart';

void main() {
  group('nullability', () {
    test('empty.isNullable', () {
      expect(empty().isNullable, false);
    });
    test('ϵ.isNullable', () {
      expect(eps().isNullable, true);
    });
    test('token.isNullable', () {
      expect(token(42).isNullable, false);
    });
    test('t[42] | t[32] . isNullable', () {
      var l = token(42) | token(43);
      expect(l.isNullable, false);
    });
    test('t[42] | eps . isNullable', () {
      var l = token(42) | eps();
      expect(l.isNullable, true);
    });

    test('t[42] | eps | t[3] . isNullable', () {
      var l = token(42) | eps() | token(3);
      expect(l.isNullable, true);
    });

    test('t[42] ∘ t[3] . isNullable', () {
      var l = token(42).seq(token(3));
      expect(l.isNullable, false);
    });

    test('t[42] ∘ eps . isNullable', () {
      var l = token(42).seq(eps());
      expect(l.isNullable, false);
    });

    test('eps ∘ t[4] . isNullable', () {
      var l = eps().seq(token(3));
      expect(l.isNullable, false);
    });
    test('eps ∘ eps . isNullable', () {
      var l = eps().seq(eps());
      expect(l.isNullable, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ϵ)', () {
      var l = (eps() | token(3)).seq(empty() | eps());
      expect(l.isNullable, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)', () {
      var l = (eps() | token(3)).seq(empty() | empty());
      expect(l.isNullable, false);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)* .isNullable', () {
      var rI = ref('I');
      var i = eps() | (empty() | empty()).seq(rI);
      rI.target = i;
      var l = (eps() | token(3)).seq(rI);
      expect(l.isNullable, true);
    });

    test('delta ∅ .isNullable', () {
      var l = empty().delta;
      expect(l.isNullable, false);
    });

    test('delta eps .isNullable', () {
      var l = eps().delta;
      expect(l.isNullable, true);
    });

    test('delta token(2) .isNullable', () {
      var l = token(2).delta;
      expect(l.isNullable, false);
    });

    test('∅.delayed(2) .isNullable', () {
      var l = empty().delayed();
      expect(l.isNullable, false);
    });

    test('ϵ.delayed(2) .isNullable', () {
      var l = eps().delayed();
      expect(l.isNullable, true);
    });

    test('tok(3).delayed(2) .isNullable', () {
      var l = token(3).delayed();
      expect(l.isNullable, false);
    });

    test('tok(3).delayed(3) .isNullable', () {
      var l = (token(3).delayed() as Delayed).force(3);
      expect(l.isNullable, true);
    });

    test('S = tok(a) | S .isNullable', () {
      var rS = ref('S');
      var l = token('a') | rS;
      rS.target = l;

      expect(l.isNullable, false);
    });

    test('S = ϵ | S .isNullable', () {
      var rS = ref('S');
      var l = eps() | rS;
      rS.target = l;

      expect(l.isNullable, true);
    });

    test('S = tok(a) | S rS.isNullable', () {
      var rS = ref('S');
      var l = token('a') | rS;
      rS.target = l;

      expect(rS.isNullable, false);
    });

    test('S = ϵ | S rS.isNullable', () {
      var rS = ref('S');
      var l = eps() | rS;
      rS.target = l;

      expect(rS.isNullable, true);
    });

    test('S = S | ϵ rS.isNullable', () {
      var rS = ref('S');
      var l = rS | eps();
      rS.target = l;

      expect(rS.isNullable, true);
    });

    test('x = ϵ | x -- e = eps .isNullable', () {
      var rx = ref('x');
      var x = eps() | rx;
      rx.target = x;

      expect(x.isNullable, true);
      expect(rx.isNullable, true);
    });

    test('self loop not nullable', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.isNullable, false);
    });

    test('derive self loop not nullable', () {
      var rS = ref('S');
      rS.target = rS;
      expect(rS.derivative('a').isNullable, false);
    });

    test('force accumulated delay', () {
      var rS = ref('S');
      rS.target = rS;

      var rsd = rS.derivative('a');
      rsd = rsd.derivative('a');
      rsd = rsd.derivative('a');
      expect(rsd.isNullable, false);
    });

    test('', () {});
  });
}
