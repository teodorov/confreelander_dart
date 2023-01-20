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
      expect(Reference('y', Token('x')).toString(), equals('ref(y)'));
    });

    test('print Delayed', () {
      expect(Delayed(Epsilon(), Empty()).toString(), equals('delayed(ε, ∅)'));
    });
  });
  group('smart constructors', () {
    test('token on object', () {
      expect(2.toToken(), isA<Token>());
      expect(2.toToken().token, 2);
      expect('toto'.toToken(), isA<Token>());
      expect('toto'.toToken().token, 'toto');
    });

    test('token function', () {
      expect(token(2), isA<Token>());
    });

    test('empty singleton', () {
      var a = Empty();
      var b = Empty();
      expect(identical(a, b), true);

      var c = empty;
      var d = empty;
      expect(identical(c, d), true);
      expect(identical(c, a), true);
    });

    test('eps', () {
      expect(eps(), isA<Epsilon>());
      var a = eps();
      var b = eps();
      expect(identical(a, b), false);
      expect(identical(a.parseTrees(), b.parseTrees()), false);

      a = epsToken(2);
      expect(a.parseTrees(), equals({2}));

      a = epsToken('to');
      expect(a.parseTrees(), equals({'to'}));

      b = epsTrees({});
      expect(identical(b, empty), false);
      b = epsTrees({empty});
      expect(identical(b, empty), false);
      b = epsTrees({
        {2},
        {'t'}
      });
      expect(
          b.parseTrees(),
          equals({
            {2},
            {'t'}
          }));
    });
    test('reference', () {
      expect(identical(empty.ref('r'), empty), true);
      expect(token(2).ref('m'), isA<Reference>());
      expect((token(2).ref('m') as Reference).target, isA<Token>());
    });
    test('', () {});
  });
}
