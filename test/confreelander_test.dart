import 'package:confreelander/src/constructors.dart';
import 'package:confreelander/src/languages.dart';

import 'package:test/test.dart';

void main() {
  group('singletons', () {
    test('empty builder singleton', () {
      expect(identical(empty(), empty()), true);
    });

    test('Empty singleton', () {
      expect(identical(Empty(), Empty()), true);
    });

    test('Empty empty singleton', () {
      expect(identical(Empty(), empty()), true);
    });

    test('Epsilon singleton', () {
      expect(identical(Epsilon(), Epsilon()), true);
    });

    test('Epsilon builder singleton', () {
      expect(identical(eps(), eps()), true);
    });

    test('Epsilon.newInstance not singleton', () {
      expect(identical(Epsilon.newInstance(), Epsilon.newInstance()), false);
    });

    test('Epsilon.newInstance different eps', () {
      expect(identical(Epsilon.newInstance(), eps()), false);
    });

    test('Epsilon.newInstance different Epsilon', () {
      expect(identical(Epsilon.newInstance(), Epsilon()), false);
    });
  });
  group('printing', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('print Empty', () {
      expect(Empty().toString(), equals('∅'));
    });

    test('print Epsilon', () {
      expect(Epsilon().toString(), equals('ε'));
    });

    test('print Token', () {
      expect(Token('toto').toString(), equals('(Token toto)'));
    });

    test('print Union', () {
      expect(Union(Token('toto'), Empty()).toString(),
          equals('((Token toto) | ∅)'));
    });

    test('print Concatenation', () {
      expect(Concatenation(Token('toto'), Empty()).toString(),
          equals('((Token toto) ∘ ∅)'));
    });

    test('print Delta', () {
      expect(Delta(Token('x')).toString(), equals('(δ (Token x))'));
    });

    test('print Reference', () {
      var r = Reference('y');
      r.target = Token('x');
      expect(r.toString(), equals('(ref y)'));
    });
  });
}
