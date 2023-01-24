import "package:characters/characters.dart";
import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('inclusion', () {
    it(String a) {
      return a.characters.iterator;
    }

    test('regular right recursive X = ϵ | aX', () {
      var rx = ref('x');
      var x = eps() | token('a').seq(rx);
      rx.target = x;

      expect(x.includes(Iterable.empty().iterator), true);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);
      expect(x.includes(it('abaa')), false);
    });

    test('regular left recursive X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      expect(x.includes(it('')), true);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);
    });

    test('regular direct recursive X = a | X', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), false);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);
    });

    test('regular direct recursive X = X | a', () {
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), false);
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
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);
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
      expect(s.includes(it('bbaabbaabb')), true);
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
      expect(a.includes(it('ab')), true);
      expect(a.includes(it('abab')), true);

      expect(a.includes(it('ababab')), true);
      expect(a.includes(it('aba')), false);
    });

    test('mutually left recursive abab...', () {
      var ra = ref('a');
      var rb = ref('b');
      var a = eps() | rb.seq(token('a'));
      var b = ra.seq(token('b'));
      ra.target = a;
      rb.target = b;

      expect(a.includes(it('')), true);
      expect(a.includes(it('ab')), true);
      expect(a.includes(it('abab')), true);

      expect(a.includes(it('ababab')), true);
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
      expect(a.includes(it('ab')), true);
      expect(a.includes(it('abab')), true);

      expect(a.includes(it('ababab')), true);
      expect(a.includes(it('aba')), false);
    });

    test('mutually direct recursive', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      expect(e.includes(it('e')), true);
      expect(e.includes(it('ee')), true);
      expect(e.includes(it('eee')), true);

      expect(e.includes(it('s')), true);
      expect(e.includes(it('ss')), true);
      expect(e.includes(it('sss')), true);

      expect(e.includes(it('es')), true);
      expect(e.includes(it('se')), true);
      expect(e.includes(it('ees')), true);
      expect(e.includes(it('ese')), true);
      expect(e.includes(it('see')), true);

      expect(e.includes(it('sse')), true);
      expect(e.includes(it('ses')), true);
      expect(e.includes(it('ess')), true);
    });
  });
}
