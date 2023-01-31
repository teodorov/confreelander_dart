// ignore_for_file: avoid_renaming_method_parameters

import 'fixer.dart';
import 'stupid_languages.dart';

extension Inhabited on Language {
  bool get isInhabited {
    return Fixer(IsInhabited())(this);
  }

  bool get isProductive => isInhabited;
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
      isInhabitedF(node.operand);

  @override
  bool visitReference(Reference node, bool Function(Language) isInhabitedF) =>
      isInhabitedF(node.target);
}
