import 'dart:collection';

import 'languages.dart';

class Fixer {
  Fixer(this.visitor);
  FunctionalVisitor<bool Function(Language), bool> visitor;
  Map<Language, bool?> fixed = HashMap.identity();
  Map<Language, bool?> transient = HashMap.identity();
  Map<Language, List<Language>> parents = HashMap.identity();
  Queue<Language> workset = ListQueue();

  bool call(Language node) {
    var property = fixed[node];
    if (property != null) return property;
    ensureTransient(node);
    while (workset.isNotEmpty) {
      var current = workset.removeFirst();
      solve(current);
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
    workset.add(node);
  }

  void solve(Language current) {
    if (fixed[current] != null) return;
    List<Language> currentChildren = [];
    bool isNullableF(Language node) {
      var property = fixed[node];
      if (property != null) return property;
      ensureTransient(node);
      currentChildren.add(node);
      return transient[node]!;
    }

    var newProperty = current.accept(visitor, isNullableF);
    for (var child in currentChildren) {
      parents.putIfAbsent(child, () => []).add(current);
    }
    if (transient[current] != newProperty) {
      transient[current] = newProperty;
      //signal the parents because the current language nullability changed
      for (var observer in parents[current]!) {
        workset.add(observer);
      }
    }
  }
}
