// ignore_for_file: avoid_renaming_method_parameters

import 'package:confreelander/src/languages.dart';

import 'fixer.dart';

extension Nullable on Language {
  bool get isNullable => Fixer(IsNullable())(this);
}

class IsNullable extends FunctionalVisitor<bool Function(Language), bool> {
  @override
  bool visitEmpty(Empty node, bool Function(Language) isNullableF) => false;

  @override
  bool visitEpsilon(Epsilon node, bool Function(Language) isNullableF) => true;

  @override
  bool visitToken(Token node, bool Function(Language) isNullableF) => false;

  @override
  bool visitUnion(Union node, bool Function(Language) isNullableF) =>
      isNullableF(node.lhs) || isNullableF(node.rhs);

  @override
  bool visitConcatenation(
          Concatenation node, bool Function(Language) isNullableF) =>
      isNullableF(node.lhs) && isNullableF(node.rhs);

  @override
  bool visitDelta(Delta node, bool Function(Language) isNullableF) =>
      isNullableF(node.operand);

  @override
  bool visitReference(Reference node, bool Function(Language) isNullableF) =>
      isNullableF(node.target);
}
