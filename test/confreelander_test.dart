import 'package:confreelander/src/languages.dart';

import 'package:test/test.dart';

void main() {
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
