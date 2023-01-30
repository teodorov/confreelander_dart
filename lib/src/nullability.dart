// ignore_for_file: avoid_renaming_method_parameters

import 'dart:collection';

import 'package:confreelander/src/stupid_languages.dart';

extension Nullability on Language {
  bool get isNullable {
    return Fixer().isNullable(this);
  }
}

class Fixer {
  Map<Language, bool?> fixed = HashMap.identity();
  Map<Language, bool?> transient = HashMap.identity();
  Map<Language, List<Language>> parents = HashMap.identity();
  Map<Language, List<Language>> children = HashMap.identity();
  Queue<Language> workset = ListQueue();

  bool isNullable(Language node) {
    var property = fixed[node];
    if (property != null) return property;
    ensureTransient(node);
    while (workset.isNotEmpty) {
      var current = workset.removeFirst();
      solveNullability(current);
    }

    for (var i in transient.entries) {
      fixed[i.key] = i.value;
    }
    return fixed[node]!;
  }

  void ensureTransient(Language node) {
    if (transient[node] != null) {
      return;
    }
    transient[node] = false;
    parents[node] = [];
    children[node] = [];
    workset.add(node);
  }

  void solveNullability(Language current) {
    if (fixed[current] != null) return;

    bool isNullableF(Language node) {
      var property = fixed[node];
      if (property != null) return property;
      parents.putIfAbsent(node, () => []).add(current);
      children.putIfAbsent(current, () => []).add(node);
      ensureTransient(node);
      return transient[node]!;
    }

    var newNullability = current.accept(LanguageIsNullable(), isNullableF);
    if (transient[current] != newNullability) {
      transient[current] = newNullability;
      //signal the parents because the current language nullability changed
      for (var observer in parents[current]!) {
        for (var child in children[observer]!) {
          parents[child]!.remove(observer);
        }
        children[observer] = [];
        workset.add(observer);
      }
    }
  }
}

class LanguageIsNullable
    extends FunctionalVisitor<bool Function(Language), bool> {
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
