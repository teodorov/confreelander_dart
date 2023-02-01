import 'dart:collection';

import 'languages.dart';

class Lattice<T> {
  Lattice(this.bottom, this.equality, [this.top]);
  T? top;
  T bottom;
  bool Function(T left, T right) equality;
}
final Lattice<bool> booleanLattice = Lattice(false, (left, right) => left == right, true);
class BooleanLattice extends Lattice<bool> {
  BooleanLattice(): super(false, (a, b) => a == b);
}
class Fixer<T> {
  Fixer(this.visitor, this.lattice);
  FunctionalVisitor<T Function(Language), T> visitor;
  Lattice<T> lattice;
  Map<Language, T?> fixed = HashMap.identity();
  Map<Language, T?> transient = HashMap.identity();
  Map<Language, List<Language>> parents = HashMap.identity();
  Queue<Language> workset = ListQueue();

  T call(Language node) {
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
    transient[node] = lattice.bottom;
    parents[node] = [];
    workset.add(node);
  }

  void solve(Language current) {
    if (fixed[current] != null) return;
    List<Language> currentChildren = [];
    T requestFunction(Language node) {
      var property = fixed[node];
      if (property != null) return property;
      ensureTransient(node);
      currentChildren.add(node);
      return transient[node] as T;
    }

    var newProperty = current.accept(visitor, requestFunction);
    for (var child in currentChildren) {
      parents.putIfAbsent(child, () => []).add(current);
    }
    if (!lattice.equality(transient[current] as T, newProperty)) {
      transient[current] = newProperty;
      //signal the parents because the current language nullability changed
      for (var observer in parents[current]!) {
        workset.add(observer);
      }
    }
  }
}
