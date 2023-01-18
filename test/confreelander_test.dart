import 'package:confreelander/confreelander.dart';
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
      expect(Token('toto').toString(), equals('Token(toto)'));
    });

    test('print Union', () {
      expect(
          Union(Token('toto'), Empty()).toString(), equals('Token(toto) | ∅'));
    });

    test('print Concatenation', () {
      expect(Concatenation(Token('toto'), Empty()).toString(),
          equals('Token(toto) ∘ ∅'));
    });

    test('print Star', () {
      expect(Star(Epsilon()).toString(), equals('ε*'));
    });

    test('print Delta', () {
      expect(Delta(Token('x')).toString(), equals('δ(Token(x))'));
    });

    test('print Projection', () {
      expect(Projection(Token('x'), (x) => true).toString(),
          equals('Token(x) >> Closure: (dynamic) => bool'));
    });

    test('print Reference', () {
      expect(Reference(Token('x')).toString(), equals('ref(Token(x))'));
    });

    test('print Delayed', () {
      expect(Delayed(Epsilon(), Empty()).toString(), equals('delayed(ε, ∅)'));
    });
  });
}
