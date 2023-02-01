// ignore_for_file: avoid_renaming_method_parameters

import 'package:confreelander/src/nullability.dart';

import 'fixer.dart';
import 'languages.dart';

extension Inhabited on Language {
  bool get isInhabited => Fixer(IsInhabited(), booleanLattice)(this);

  bool get isProductive => isInhabited;

  bool get maybeInhabited => Fixer(MaybeInhabited(), booleanLattice)(this);
}

class IsInhabited extends FunctionalVisitor<bool Function(Language), bool> {
  @override
  bool visitEmpty(Empty node, bool Function(Language) isInhabitedF) => false;
  @override
  bool visitEpsilon(Epsilon node, bool Function(Language) isInhabitedF) => true;
  @override
  bool visitToken(Token node, bool Function(Language) isInhabitedF) => true;

  @override
  bool visitUnion(Union node, bool Function(Language) isInhabitedF) =>
      isInhabitedF(node.lhs) || isInhabitedF(node.rhs);
  @override
  bool visitConcatenation(
          Concatenation node, bool Function(Language) isInhabitedF) =>
      isInhabitedF(node.lhs) && isInhabitedF(node.rhs);
  @override
  bool visitDelta(Delta node, bool Function(Language) isInhabitedF) =>
      node.operand.isNullable;

  @override
  bool visitReference(Reference node, bool Function(Language) isInhabitedF) =>
      isInhabitedF(node.target);
}

class MaybeInhabited extends IsInhabited {
  @override
  bool visitReference(
          Reference node, bool Function(Language p1) isInhabitedF) =>
      node.target.isEmpty ? true : isInhabitedF(node.target);
}
