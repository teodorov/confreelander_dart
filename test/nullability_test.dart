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

    /// Given by ChatGPT
    ///S -> A B
    ///A -> C | epsilon
    ///B -> C | epsilon
    ///C -> S
    test('sabc', () {
      var rS = ref('S');
      var rA = ref('A');
      var rB = ref('B');
      var rC = ref('C');
      var s = rA.seq(rB);
      var a = rC | eps();
      var b = rC | eps();
      var c = rS;
      rS.target = s;
      rA.target = a;
      rB.target = b;
      rC.target = c;

      expect(s.isNullable, true);
      expect(c.isNullable, true);
    });

    /// Given by ChatGPT
    ///S -> A B
    ///A -> a | epsilon
    ///B -> b | epsilon
    test('sab', () {
      var rS = ref('S');
      var rA = ref('A');
      var rB = ref('B');

      var s = rA.seq(rB);
      var a = token('a') | eps();
      var b = token('b') | eps();

      rS.target = s;
      rA.target = a;
      rB.target = b;

      expect(s.isNullable, true);
      expect(a.isNullable, true);
      expect(b.isNullable, true);
    });

    /// Given by ChatGPT
    ///S -> A B
    ///A -> C | epsilon
    ///B -> D | epsilon
    ///C -> a A D
    ///D -> b B C
    test('sab', () {
      var rS = ref('S');
      var rA = ref('A');
      var rB = ref('B');
      var rC = ref('C');
      var rD = ref('D');
      var s = rA.seq(rB);
      var a = rC | eps();
      var b = rD | eps();
      var c = token('a').seq(rA).seq(rD);
      var d = token('b').seq(rB).seq(rC);
      rS.target = s;
      rA.target = a;
      rB.target = b;
      rC.target = c;
      rD.target = d;

      expect(s.isNullable, true);
      expect(a.isNullable, true);
      expect(b.isNullable, true);
      expect(c.isNullable, true);
      expect(d.isNullable, true);
    });
  });
}
