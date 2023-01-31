import 'dart:io';

import "package:characters/characters.dart";
import 'package:collection/collection.dart';
import 'package:confreelander/src/language_to_tgf.dart';
import 'package:confreelander/src/nullability.dart';
import 'package:confreelander/src/constructors.dart';
import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/derivative_iterable.dart';
import 'package:test/test.dart';

void main() {
  group('inclusion', () {
    it(String a) {
      return a.characters.iterator;
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

      x.derivatives('aaaaa'.characters).forEachIndexed((index, dpT) {
        File('dX$index.tgf').writeAsStringSync(dpT.toTGF());
      });

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

      expect(x.includes(Iterable.empty().iterator), true);
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

      File('epsinXa.tgf').writeAsStringSync(x.toTGF());
      expect(x.includes(it('')), true);
    });

    test('regular left recursive \'a\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('ainXa.tgf').writeAsStringSync(x.derivative('a').toTGF());

      expect(x.includes(it('a')), true);
    });

    test('regular left recursive aa ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('aainXa.tgf')
          .writeAsStringSync(x.derivative('a').derivative('a').toTGF());
      expect(x.includes(it('aa')), true);
    });

    test('regular left recursive \'ab\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('abinXa.tgf')
          .writeAsStringSync(x.derivative('a').derivative('b').toTGF());
      expect(x.includes(it('ab')), false);
    });

    test('regular left recursive \'ba\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('bainXa.tgf')
          .writeAsStringSync(x.derivative('b').derivative('a').toTGF());
      expect(x.includes(it('ba')), false);
    });

    test('regular left recursive \'aaa\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('aaainXa.tgf').writeAsStringSync(
          x.derivative('a').derivative('a').derivative('a').toTGF());

      expect(x.includes(it('aaa')), true);
    });

    test('regular left recursive \'aab\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('aabinXa.tgf').writeAsStringSync(
          x.derivative('a').derivative('a').derivative('b').toTGF());

      expect(x.includes(it('aab')), false);
    });

    test('regular left recursive \'aba\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;

      File('abainXa.tgf').writeAsStringSync(
          x.derivative('a').derivative('b').derivative('a').toTGF());

      expect(x.includes(it('aba')), false);
    });

    test('regular left recursive \'aaaa\' ∈ X = ϵ | Xa', () {
      var rx = ref('x');
      var x = eps() | rx.seq(token('a'));
      rx.target = x;
      File('aaaainXa.tgf').writeAsStringSync(x
          .derivative('a')
          .derivative('a')
          .derivative('a')
          .derivative('a')
          .toTGF());
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
      expect(x.includes(it('aa')), false);
    });

    test('X = a | X, (d (d X b) a)', () {
      print('\n-----(d (d X b) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('ddXba.tgf')
          .writeAsStringSync(x.derivative('b').derivative('a').toTGF());

      rx = ref('x');
      x = token('a') | rx;
      rx.target = x;
      expect(x.includes(it('ba')), false);
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
      expect(x.includes(it('aaa')), false);
    });

    test('X = a | X, (d (d (d X b) a) a)', () {
      print('\n-----(d (d (d X b) a) a)----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      File('dddXbaa.tgf').writeAsStringSync(
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
      // expect(s.includes(it('[[]][][[[][]]]')), true);
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
      // expect(s.includes(it('[[]][][[[][]]]')), true);
    });

    test('mutually right recursive abab...', () {
      var ra = ref('a');
      var rb = ref('b');
      var a = token('a').seq(rb) | eps();
      var b = token('b').seq(ra);
      ra.target = a;
      rb.target = b;

      expect(a.includes(it('')), true);

      File('abab.tgf')
          .writeAsStringSync(a.derivative('a').derivative('b').toTGF());
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

      File('baba.tgf').writeAsStringSync(a
          .derivative('b')
          .derivative('a')
          .derivative('b')
          .derivative('a')
          .toTGF());

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
      expect(e.includes(it('es')), false);
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
