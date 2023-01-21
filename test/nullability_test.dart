import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('nullability', () {
    test('empty.isNullable', () {
      expect(empty.isNullable, false);
    });
    test('ϵ.isNullable', () {
      expect(eps().isNullable, true);
      expect(epsToken(2).isNullable, true);
      expect(epsTrees({2}).isNullable, true);
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
      var l = (eps() | token(3)).seq(empty | eps());
      expect(l.isNullable, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)', () {
      var l = (eps() | token(3)).seq(empty | empty);
      expect(l.isNullable, false);
    });
    test('t(3).star.isNullable', () {
      var l = token(3).star;
      expect(l.isNullable, true);
    });

    test('∅* .isNullable', () {
      var l = empty.star;
      expect(l.isNullable, true);
    });

    test('(ϵ | t(3)) ∘ (∅ | ∅)* .isNullable', () {
      var l = (eps() | token(3)).seq((empty | empty).star);
      expect(l.isNullable, true);
    });

    test('delta ∅ .isNullable', () {
      var l = empty.delta;
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

    test('∅ >> f .isNullable', () {
      var l = empty >> (v) => print(v);
      expect(l.isNullable, false);
    });

    test('ϵ >> f .isNullable', () {
      var l = eps() >> (v) => v;
      expect(l.isNullable, true);
    });

    test('tok(3) >> f .isNullable', () {
      var l = token(3) >> (v) => print(v);
      expect(l.isNullable, false);
    });

    test('∅.delayed(2) .isNullable', () {
      var l = empty.delayed(2);
      expect(l.isNullable, false);
    });

    test('ϵ.delayed(2) .isNullable', () {
      var l = eps().delayed(2);
      expect(l.isNullable, false);
    });

    test('tok(3).delayed(2) .isNullable', () {
      var l = token(3).delayed(2);
      expect(l.isNullable, false);
    });

    test('tok(3).delayed(3) .isNullable', () {
      var l = token(3).delayed(3);
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

    test('S = S* .isNullable', () {
      var rS = ref('S');
      var l = rS.star;
      rS.target = l;

      expect(l.isNullable, true);
    });

    test('S = S* rS.isNullable', () {
      var rS = ref('S');
      var l = rS.star;
      rS.target = l;

      expect(rS.isNullable, true);
    });

    test('', () {});
  });
}
