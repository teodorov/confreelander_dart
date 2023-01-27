import 'dart:io';

import "package:characters/characters.dart";
import 'package:confreelander/src/stupid_constructors.dart';
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

      // print('\n-----X----\n');
      // File('Lx.tgf').writeAsStringSync(x.toTGF());

      // print('\n-----dX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Ldx.tgf').writeAsStringSync(x.derivative('a').toTGF());

      // print('\n-----bX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Lbx.tgf').writeAsStringSync(x.derivative('b').toTGF());

      // print('\n-----dbX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Ldbx.tgf')
      //     .writeAsStringSync(x.derivative('a').derivative('b').toTGF());

      // print('\n-----ddX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Lddx.tgf')
      //     .writeAsStringSync(x.derivative('a').derivative('a').toTGF());

      // print('\n-----dddX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Ldddx.tgf').writeAsStringSync(
      //     x.derivative('a').derivative('a').derivative('a').toTGF());

      // print('\n-----dbdX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;
      // File('Ldbdx.tgf').writeAsStringSync(
      //     x.derivative('a').derivative('b').derivative('a').toTGF());

      // print('\n-----ddddX----\n');
      // rx = ref('x');
      // x = token('a') | rx;
      // rx.target = x;

      // File('Lddddx.tgf').writeAsStringSync(x
      //     .derivative('a')
      //     .derivative('a')
      //     .derivative('a')
      //     .derivative('a')
      //     .toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('')), false);
      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('a')), true);

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aaa')), true);
      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aaaa')), true);
    });

    test('X = a | X, (d X a)', () {
      print('\n-----(d X a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dXa.tgf').writeAsStringSync(x.derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('a')), true);
    });

    test('X = a | X, (d X b)', () {
      print('\n-----(d X b)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dXb.tgf').writeAsStringSync(x.derivative('b').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('b')), false);
    });

    test('X = a | X, (d (d X a) a)', () {
      print('\n-----(d (d X a) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('ddXaa.tgf')
          .writeAsStringSync(x.derivative('a').derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aa')), true);
    });

    test('X = a | X, (d (d X a) b)', () {
      print('\n-----(d (d X a) b)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('ddXab.tgf')
          .writeAsStringSync(x.derivative('a').derivative('b').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('ab')), false);
    });

    test('X = a | X, (d (d (d X a) a) a)', () {
      print('\n-----(d (d (d X a) a) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dddXaaa.tgf').writeAsStringSync(
          x.derivative('a').derivative('a').derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aaa')), true);
    });

    test('X = a | X, (d (d (d X b) a) a)', () {
      print('\n-----(d (d (d X b) a) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dddXaaa.tgf').writeAsStringSync(
          x.derivative('b').derivative('a').derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('baa')), false);
    });

    test('X = a | X, (d (d (d X a) b) a)', () {
      print('\n-----(d (d (d X a) b) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dddXaba.tgf').writeAsStringSync(
          x.derivative('a').derivative('b').derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('aba')), false);
    });

    test('X = a | X, (d (d (d X a) a) b)', () {
      print('\n-----(d (d (d X a) a) b)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dddXaab.tgf').writeAsStringSync(
          x.derivative('a').derivative('a').derivative('b').toTGF());

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

    test('regular direct recursive X = b | a | X', () {
      var rx = ref('x');
      var x = token('b') | token('a') | rx;
      rx.target = x;

      expect(x.includes(it('')), false);
      expect(x.includes(it('a')), true);
      expect(x.includes(it('aa')), true);
      expect(x.includes(it('aaa')), true);
      expect(x.includes(it('aaaa')), true);

      expect(x.includes(it('b')), true);
      expect(x.includes(it('bb')), true);
      expect(x.includes(it('bbb')), true);
      expect(x.includes(it('bbbb')), true);

      expect(x.includes(it('ab')), true);
      expect(x.includes(it('ba')), true);

      expect(x.includes(it('abb')), true);
      expect(x.includes(it('bab')), true);
      expect(x.includes(it('bba')), true);

      expect(x.includes(it('aab')), true);
      expect(x.includes(it('baa')), true);
      expect(x.includes(it('aba')), true);
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
      expect(a.includes(it('ab')), true);
      expect(a.includes(it('abab')), true);

      expect(a.includes(it('ababab')), true);
      expect(a.includes(it('aba')), true);
    });

    test('E = e | S. S = s | E, (d E e)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      print('\n-----(d E e)----\n');
      File('dEe.tgf').writeAsStringSync(e.derivative('e').toTGF());

      expect(e.includes(it('e')), true);
    });

    test('E = e | S. S = s | E, (d (d E e) s)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      print('\n-----(d (d E e) s)----\n');
      File('ddEes.tgf')
          .writeAsStringSync(e.derivative('e').derivative('s').toTGF());

      rE = ref('E');
      rS = ref('S');
      e = token('e') | rS;
      s = token('s') | rE;
      rE.target = e;
      rS.target = s;
      expect(e.includes(it('es')), true);
    });

    test('E = e | S. S = s | E, (d (d E e) e)', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      print('\n-----(d (d E e) e)----\n');
      File('ddEee.tgf')
          .writeAsStringSync(e.derivative('e').derivative('e').toTGF());

      expect(e.includes(it('ee')), true);
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
