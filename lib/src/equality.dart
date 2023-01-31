import 'dart:collection';

import 'package:confreelander/src/languages.dart';

// ignore_for_file: avoid_renaming_method_parameters
class IsEqual extends FunctionalVisitor<Object?, bool> {
  bool isEqual(Language a, Language b) {
    return a.accept(this, b);
  }

  @override
  bool visitEmpty(Empty node, Object? other) => other is Empty;
  @override
  bool visitEpsilon(Epsilon node, Object? other) => other is Epsilon;

  @override
  bool visitToken(Token node, Object? other) =>
      identical(node, other) || (other is Token && node.token == other.token);

  @override
  bool visitUnion(Union node, Object? other) =>
      identical(node, other) ||
      (other is Union &&
          isEqual(node.lhs, other.lhs) &&
          isEqual(node.rhs, other.rhs));

  @override
  bool visitConcatenation(Concatenation node, Object? other) =>
      identical(node, other) ||
      (other is Concatenation &&
          isEqual(node.lhs, other.lhs) &&
          isEqual(node.rhs, other.rhs));

  @override
  bool visitDelta(Delta node, Object? other) =>
      identical(node, other) ||
      (other is Delta && isEqual(node.operand, other.operand));

  Map<Reference, Reference> candidateMap = HashMap.identity();

  @override
  bool visitReference(Reference node, Object? other) {
    if (identical(node, other)) return true;
    if (other is! Reference) return false;

    var candidate = candidateMap[node];
    if (candidate != null) {
      return identical(candidate, other);
    }
    candidateMap[node] = other;
    return isEqual(node.target, other.target);
  }
}

class HashCode extends FunctionalVisitor<void, int> {
  int hashCodeOf(Language a) {
    return a.accept(this, null);
  }

  @override
  int visitEmpty(Empty node, void input) => identityHashCode(node);
  @override
  int visitEpsilon(Epsilon node, void input) => identityHashCode(node);

  @override
  int visitToken(Token node, void input) =>
      Object.hash(node.runtimeType, node.token);

  @override
  int visitUnion(Union node, void input) =>
      Object.hash(node.runtimeType, hashCodeOf(node.lhs), hashCodeOf(node.rhs));

  @override
  int visitConcatenation(Concatenation node, void input) =>
      Object.hash(node.runtimeType, hashCodeOf(node.lhs), hashCodeOf(node.rhs));

  @override
  int visitDelta(Delta node, void input) =>
      Object.hash(node.runtimeType, hashCodeOf(node.operand));

  Map<Reference, int> candidateMap = HashMap.identity();

  @override
  int visitReference(Reference node, void input) {
    var candidate = candidateMap[node];
    if (candidate != null) return candidate;
    candidateMap[node] = node.runtimeType.hashCode;
    return Object.hash(node.runtimeType, hashCodeOf(node.target));
  }
}
