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
      return Fixer(ParseTreeVisitor(derivativeVisitor.epsilonParseTrees),
          setLattice)(current);
    }
    return {};
  }
  ParserDerivative parserDerivative(Object token) {
    var derivativeVisitor = ParsingDerivative();
    var languageDerivative = accept(derivativeVisitor, token);
    return ParserDerivative(languageDerivative, derivativeVisitor.epsilonParseTrees);
  }
}

class ParserDerivative {
  ParserDerivative(this.language, this.epsilonParseTrees);
  Language language;
  Expando<Set> epsilonParseTrees;

  ParserDerivative parserDerivative(Object token) {
    var derivativeVisitor = ParsingDerivative.withParseTree(epsilonParseTrees);
    var languageDerivative = language.accept(derivativeVisitor, token);
    return ParserDerivative(languageDerivative, epsilonParseTrees);
  }
}

class ParsingDerivative extends LanguageDerivative {
  ParsingDerivative();
  ParsingDerivative.withParseTree(this.epsilonParseTrees);
  Expando<Set> epsilonParseTrees = Expando('epsilonParseTrees');
  @override
  Language visitToken(Token node, Object input) {
    if (node.token != input) return empty();
    var derivative = Epsilon.newInstance();
    epsilonParseTrees[derivative] = {node.token};
    return derivative;
  }
}

class ParseTreeVisitor extends FunctionalVisitor<Set Function(Language), Set> {
  ParseTreeVisitor(this.epsilonParseTrees);
  Expando<Set> epsilonParseTrees;
  @override
  Set visitEmpty(Empty node, Set Function(Language) parseTreeF) => {};

  @override
  Set visitEpsilon(Epsilon node, Set Function(Language) parseTreeF) =>
      epsilonParseTrees[node] ?? {};

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
