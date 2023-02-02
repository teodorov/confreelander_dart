import 'package:characters/characters.dart';

import 'package:confreelander/src/constructors.dart';
import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/parsing.dart';
import 'package:test/test.dart';

void main() {
  group('parser', () {
    test('a', () {
      var s = token('a');
      var word = 'a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print('-'*10 + s.toString());
      expect('$parseTree', '{a}');
    });

    test('a|b', () {
      var s = token('a') | token('b');
      var word = 'a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print('-'*10 + s.toString());
      // print(parseTree);
      expect('$parseTree', '{a}');

      word = 'b'.characters;
      expect(s.includes(word), true);
      parseTree = s.parse(word);
      // print('-'*10 + s.toString());
      // print(parseTree);
      expect('$parseTree', '{b}');
    });

    test('a|a', () {
      var s = token('a') | token('a');
      var word = 'a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print('-'*10 + s.toString());
      // print(parseTree);
      expect('$parseTree', '{a}');
    });

    test('ab', () {
      var s = token('a').seq(token('b'));
      var word = 'ab'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print('-' * 10 + s.toString());
      // print(parseTree);
      expect('$parseTree', '{[a, b]}');
    });

    test('abc', () {
      var s = token('a').seq(token('b').seq(token('c')));
      var word = 'abc'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print('-' * 10 + s.toString());
      print(parseTree);
      expect('$parseTree', '{[a, [b, c]]}');
    });

    test('S = S ((t +) S) | (t a) -- a+a', () {
      var rS = ref('S');
      var s = rS.seq(token('+').seq(rS)) | token('a');
      rS.target = s;

      var word = 'a+a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print(parseTree);
      expect('$parseTree', '{[a, [+, a]]}');
    });

    test('S = S ((t +) S) | (t a) -- a+a+a', () {
      var rS = ref('S');
      var s = rS.seq(token('+').seq(rS)) | token('a');
      rS.target = s;

      var word = 'a+a+a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print(parseTree);
      expect('$parseTree', '{[a, [+, [a, [+, a]]]], [[a, [+, a]], [+, a]]}');
    });

    test('S = (S (t +)) S | (t a) -- a+a', () {
      var rS = ref('S');
      var s = rS.seq(token('+')).seq(rS) | token('a');
      rS.target = s;

      var word = 'a+a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print(parseTree);
      expect('$parseTree', '{[[a, +], a]}');
    });

    test('S = (S (t +)) S | (t a) -- a+a+a', () {
      var rS = ref('S');
      var s = rS.seq(token('+')).seq(rS) | token('a');
      rS.target = s;

      var word = 'a+a+a'.characters;
      expect(s.includes(word), true);
      var parseTree = s.parse(word);
      // print(parseTree);
      expect('$parseTree', '{[[a, +], [[a, +], a]], [[[[a, +], a], +], a]}');
    });
  });
}
