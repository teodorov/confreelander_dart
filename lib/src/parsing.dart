// ignore_for_file: avoid_renaming_method_parameters

import 'package:collection/collection.dart';
import 'package:confreelander/confreelander.dart';
import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/nullability.dart';

import 'constructors.dart';
import 'fixer.dart';

Lattice<Set> setLattice =
    Lattice(<dynamic>{}, (left, right) => SetEquality().equals(left, right));

extension DerivativeParsing on Language {
  Set parse(Iterable iterable) {
    var current = this;
    var derivativeVisitor = ParsingDerivative();
    for (var token in iterable) {
      current = current.accept(derivativeVisitor, token);
    }
    if (current.isNullable) {
      return Fixer(ParseTreeBuilder(), setLattice)(current);
    }
    return {};
  }
}

class EpsilonParser extends Epsilon {
  EpsilonParser(token) : super.newInstance() {
    parseTrees.add(token);
  }
  Set parseTrees = {};

  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    if (visitor is ParserFunctionalVisitor) {
      return (visitor as ParserFunctionalVisitor)
          .visitEpsilonParser(this, input);
    }
    return visitor.visitEpsilon(this, input);
  }
}

class ParserFunctionalVisitor<I, O> extends FunctionalVisitor<I, O> {
  O visitEpsilonParser(EpsilonParser node, I input) {
    throw UnimplementedError('missing visitor method');
  }
}

class ParsingDerivative extends LanguageDerivative {
  @override
  Language visitToken(Token node, Object input) =>
      node.token == input ? EpsilonParser(node.token) : empty();
}

class ParseTreeBuilder
    extends ParserFunctionalVisitor<Set Function(Language), Set> {
  @override
  Set visitEmpty(Empty node, Set Function(Language) parseTreeF) => {};

  @override
  Set visitEpsilon(Epsilon node, Set Function(Language) parseTreeF) =>
      throw Exception('should not use for parsing');

  @override
  Set visitEpsilonParser(
          EpsilonParser node, Set Function(Language) parseTreeF) =>
      node.parseTrees;

  @override
  Set visitToken(Token node, Set Function(Language) parseTreeF) => {};

  @override
  Set visitUnion(Union node, Set Function(Language) parseTreeF) =>
      parseTreeF(node.lhs).union(parseTreeF(node.rhs));

  ///Concatenation nodes construct pairs of elements from their children
  @override
  Set visitConcatenation(
      Concatenation node, Set Function(Language) parseTreeF) {
    var lhsTrees = parseTreeF(node.lhs);
    var rhsTrees = parseTreeF(node.rhs);

    Set result = {};
    for (var lhsTree in lhsTrees) {
      for (var rhsTree in rhsTrees) {
        result.add([lhsTree, rhsTree]);
      }
    }
    return result;
  }

  @override
  Set visitDelta(Delta node, Set Function(Language) parseTreeF) =>
      parseTreeF(node.operand);

  @override
  Set visitReference(Reference node, Set Function(Language) parseTreeF) =>
      parseTreeF(node.target);
}
