import "package:characters/characters.dart";
import 'package:confreelander/src/nullability.dart';
import 'package:confreelander/src/constructors.dart';
import 'package:confreelander/src/derivative.dart';
import 'package:test/test.dart';

void main() {
  group('inclusion', () {
    it(String a) {
      return a.characters;
    }

    test('self reference X = X, (d X a)', () {
      var rx = ref('x');
      rx.target = rx;

      expect(rx.includes(it('')), false);
      expect(rx.includes(it('a')), false);
      expect(rx.includes(it('aa')), false);
      expect(rx.includes(it('aaa')), false);
      expect(rx.includes(it('ab')), false);
    });

    test('self reference X = Xa, (d Xa a)', () {
      var rx = ref('x');
      var x = rx.seq(token('a'));
      rx.target = x;

      expect(rx.includes(it('')), false);
      expect(rx.includes(it('a')), false);
      expect(rx.includes(it('aa')), false);
      expect(rx.includes(it('aaa')), false);
      expect(rx.includes(it('ab')), false);
    });

    test('regular right recursive X = ϵ | aX', () {
      var rx = ref('x');
      var x = eps() | token('a').seq(rx);
      rx.target = x;

      expect(x.includes(Iterable.empty()), true);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('ba')), false);
      expect(x.includes(it('ab')), false);
      expect(x.includes(it('bb')), false);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('baa')), false);
      expect(x.includes(it('aba')), false);
      expect(x.includes(it('aab')), false);
      expect(x.includes(it('aaaa')), true);
      expect(x.includes(it('abaa')), false);
    });

    test('regular left recursive \'\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('')), true);
    });

    test('regular left recursive \'a\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('a')), true);
    });

    test('regular left recursive aa ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('aa')), true);
    });

    test('regular left recursive \'ab\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      // File('abinXa.tgf')
      //     .writeAsStringSync(x.derivative('a').derivative('b').toTGF());
      expect(x.includes(it('ab')), false);
    });

    test('regular left recursive \'ba\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('ba')), false);
    });

    test('regular left recursive \'aaa\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('aaa')), true);
    });

    test('regular left recursive \'aab\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('aab')), false);
    });

    test('regular left recursive \'aba\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('aba')), false);
    });

    test('regular left recursive \'aaaa\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('aaaa')), true);
    });

    test('X = a | X, (d X a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('a')), true);
    });

    test('X = a | X, (d X b)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('b')), false);
    });

    test('X = a | X, (d (d X a) a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aa')), false);
    });

    test('X = a | X, (d (d X b) a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('ba')), false);
    });

    test('X = a | X, (d (d X a) b)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('ab')), false);
    });

    test('X = a | X, (d (d (d X a) a) a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aaa')), false);
    });

    test('X = a | X, (d (d (d X b) a) a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('baa')), false);
    });

    test('X = a | X, (d (d (d X a) b) a)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aba')), false);
    });

    test('X = a | X, (d (d (d X a) a) b)', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aab')), false);
    });

    test('regular direct recursive X = a | X, no copy', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('')), false);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), false);
      expect(x.includes(it('aaa')), false);
      expect(x.includes(it('aaaa')), false);
    });

    test('regular direct recursive X = X | a', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), false);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), false);
      expect(x.includes(it('aaa')), false);
      expect(x.includes(it('aaaa')), false);
    });

    test('left recursive X = Xa | ϵ', () {
      var rx = ref('x');
      var x = rx.seq(token('a')) | eps();
      rx.target = x;

      expect(x.includes(it('')), true);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);
    });

    test('regular direct recursive X = ϵ | a | X', () {
      var rx = ref('x');
      var x = eps() | token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), true);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), false);
      expect(x.includes(it('aaa')), false);
      expect(x.includes(it('aaaa')), false);
    });

    test('regular direct recursive X = b | a | X', () {
      var rx = ref('x');
      var x = token('b') | token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), false);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), false);
      expect(x.includes(it('aaa')), false);
      expect(x.includes(it('aaaa')), false);

      expect(x.includes(it('b')), true);
      expect(x.includes(it('bb')), false);
      expect(x.includes(it('bbb')), false);
      expect(x.includes(it('bbbb')), false);

      expect(x.includes(it('ab')), false);
      expect(x.includes(it('ba')), false);

      expect(x.includes(it('abb')), false);
      expect(x.includes(it('bab')), false);
      expect(x.includes(it('bba')), false);

      expect(x.includes(it('aab')), false);
      expect(x.includes(it('baa')), false);
      expect(x.includes(it('aba')), false);
    });

    test('word ∘ drow', () {
      var rs = ref('s');
      var s = eps() |
          token('a').seq(rs).seq(token('a')) |
          token('b').seq(rs).seq(token('b'));
      rs.target = s;

      expect(s.includes(it('')), true);
      expect(s.includes(it('aa')), true);
      expect(s.includes(it('ab')), false);
      expect(s.includes(it('bb')), true);
      expect(s.includes(it('aabbaa')), true);
      expect(s.includes(it('bbaabb')), true);
      // expect(s.includes(it('bbaabbaabb')), true);
    });

    test('well-formed parens', () {
      var rs = ref('s');
      var s = rs.seq(rs) |
          token('[').seq(rs).seq(token(']')) |
          token('[').seq(token(']'));
      rs.target = s;

      expect(s.includes(it('[]')), true);
      expect(s.includes(it('[')), false);
      expect(s.includes(it(']')), false);
      expect(s.includes(it('[[]]')), true);
      expect(s.includes(it('[[]')), false);
      expect(s.includes(it('[[]][]')), true);
      expect(s.includes(it('[[]][][[[][]]]')), true);
    });

    test('well-formed parens 1', () {
      var rs = ref('s');
      var s = rs.seq(rs) |
          token('[').seq(token(']')) |
          token('[').seq(rs).seq(token(']'));

      rs.target = s;

      expect(s.includes(it('[]')), true);
      expect(s.includes(it('[')), false);
      expect(s.includes(it(']')), false);
      expect(s.includes(it('[[]]')), true);
      expect(s.includes(it('[[]')), false);
      expect(s.includes(it('[[]][]')), true);
      expect(s.includes(it('[[]][][[[][]]]')), true);
    });

    test('mutually right recursive abab...', () {
      var ra = ref('a');
      var rb = ref('b');
      var a = token('a').seq(rb) | eps();
      var b = token('b').seq(ra);
      ra.target = a;
      rb.target = b;

      expect(a.includes(it('')), true);

      expect(a.derivative('a').isNullable, false);
      expect(a.derivative('a').derivative('b').isNullable, true);

      expect(a.includes(it('ab')), true);
      expect(a.includes(it('abab')), true);

      expect(a.includes(it('ababab')), true);
      expect(a.includes(it('aba')), false);
      expect(a.includes(it('ba')), false);
      expect(a.includes(it('baba')), false);
      expect(a.includes(it('bababa')), false);
      expect(a.includes(it('bababa')), false);
    });

    test('mutually left recursive abab...', () {
      var ra = ref('a');
      var rb = ref('b');
      var a = eps() | rb.seq(token('a'));
      var b = ra.seq(token('b'));
      ra.target = a;
      rb.target = b;

      // A = ϵ | Ba
      // B = Ab

      expect(a.includes(it('')), true);
      expect(a.includes(it('ba')), true);

      expect(a.includes(it('baba')), true);
      expect(a.includes(it('bababa')), true);
      expect(a.includes(it('bababa')), true);
      expect(a.includes(it('ab')), false);
      expect(a.includes(it('abab')), false);

      expect(a.includes(it('ababab')), false);
      expect(a.includes(it('aba')), false);
    });

    test('mutually direct recursive abab...', () {
      var ra = ref('a');
      var rb = ref('b');
      var a = eps() | token('a') | rb;
      var b = token('b') | ra;
      ra.target = a;
      rb.target = b;

      expect(a.includes(it('')), true);
      expect(a.includes(it('a')), true);
      expect(a.includes(it('b')), true);

      expect(a.includes(it('ababab')), false);
      expect(a.includes(it('aba')), false);
    });

    test('E = e | S. S = s | E, (d E e)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      expect(e.includes(it('e')), true);
    });

    test('E = e | S. S = s | E, (d (d E e) s)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      rE = ref('E');
      rS = ref('S');
      e = token('e') | rS;
      s = token('s') | rE;
      rE.target = e;
      rS.target = s;
      expect(e.includes(it('es')), false);
    });

    test('E = e | S. S = s | E, (d (d E e) e)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      expect(e.includes(it('ee')), false);
    });

    test('mutually direct recursive', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      expect(e.includes(it('e')), true);
      expect(e.includes(it('ee')), false);
      expect(e.includes(it('eee')), false);

      expect(e.includes(it('s')), true);
      expect(e.includes(it('ss')), false);
      expect(e.includes(it('sss')), false);

      expect(e.includes(it('es')), false);
      expect(e.includes(it('se')), false);
      expect(e.includes(it('ees')), false);
      expect(e.includes(it('ese')), false);
      expect(e.includes(it('see')), false);

      expect(e.includes(it('sse')), false);
      expect(e.includes(it('ses')), false);
      expect(e.includes(it('ess')), false);
    });
  });
}
