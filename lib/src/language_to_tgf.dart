import 'dart:collection';

import 'package:confreelander/src/stupid_languages.dart';

extension Language2TGF on Language {
  toTGF() {
    Map<Language, String> nodeMap = HashMap.identity();
    String links = accept(LanguageToTGF(), nodeMap);
    String nodes = nodeMap.values.join('\n');
    return '0 0\n$nodes\n#\n0 ${identityHashCode(this)}\n$links';
  }
}

class LanguageToTGF extends FunctionalVisitor<Map<Language, String>, String> {
  computeTGF(node, map) {
    return node.accept(this, map);
  }

  @override
  String visitEmpty(Empty node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} ∅';
    return '';
  }

  @override
  String visitEpsilon(Epsilon node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} ϵ';
    return '';
  }

  @override
  String visitToken(Token node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} (τ $node.token)';
    return '';
  }

  @override
  String visitUnion(Union node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} |';
    var lhsL = computeTGF(node.lhs, input);
    var rhsL = computeTGF(node.rhs, input);
    return '$lhsL\n$rhsL\n${identityHashCode(node)} ${identityHashCode(node.lhs)} l\n${identityHashCode(node)} ${identityHashCode(node.rhs)} r\n';
  }

  @override
  String visitConcatenation(Concatenation node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} ∘';
    var lhsL = computeTGF(node.lhs, input);
    var rhsL = computeTGF(node.rhs, input);
    return '$lhsL\n$rhsL\n${identityHashCode(node)} ${identityHashCode(node.lhs)} l\n${identityHashCode(node)} ${identityHashCode(node.rhs)} r\n';
  }

  @override
  String visitDelta(Delta node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} δ';
    var opL = computeTGF(node.operand, input);
    return '$opL\n${identityHashCode(node)} ${identityHashCode(node.operand)}\n';
  }

  @override
  String visitReference(Reference node, Map<Language, String> input) {
    if (input[node] != null) return '';
    input[node] = '${identityHashCode(node)} μ';
    var opL = computeTGF(node.target, input);
    return '$opL\n${identityHashCode(node)} ${identityHashCode(node.target)}\n';
  }
}
