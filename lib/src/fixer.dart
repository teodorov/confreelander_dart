import 'dart:collection';

import 'stupid_languages.dart';

class TaggedLink<D> {
  TaggedLink(this.vertex1, this.vertex2);
  Node<D> vertex1, vertex2;
  bool destroyed = false;
}

class Node<D> {
  Node(this.data);
  D data;
  List<TaggedLink<D>> incoming = [];
  List<TaggedLink<D>> outgoing = [];
  bool mark = false;
}

class DependencyGraph<D> {
  Map<D, Node<D>> nodes = {};
  List<D> predecessors(D data) {
    Node<D>? node = nodes[data];
    if (node == null) return [];
    var alive = node.incoming.where((link) => !link.destroyed).toList();
    node.incoming = alive;
    return node.incoming
        .map((e) => e.vertex1 == node ? e.vertex2.data : e.vertex1.data)
        .toList();
  }

  void setSuccessors(D sourceData, List<D> successors) {
    var sourceNode = nodes.putIfAbsent(sourceData, () => Node(sourceData));
    List<Node<D>> targets = [];
    for (var successor in successors) {
      var targetNode = nodes.putIfAbsent(successor, () => Node(successor));
      //do not add duplicates
      if (targetNode.mark = true) continue;
      targetNode.mark = true;
      targets.add(targetNode);
      var link = TaggedLink(sourceNode, targetNode);
      sourceNode.outgoing.add(link);
      targetNode.incoming.add(link);
    }
    //clear the marks
    for (var t in targets) {
      t.mark = false;
    }
  }

  void clearSuccessors(D data) {
    Node? node = nodes[data];
    if (node == null) return;
    for (var n in node.outgoing) {
      n.destroyed = true;
    }
    node.outgoing = [];
  }
}

class Fixer {
  Fixer(this.visitor);
  FunctionalVisitor<bool Function(Language), bool> visitor;
  Map<Language, bool?> fixed = HashMap.identity();
  Map<Language, bool?> transient = HashMap.identity();
  DependencyGraph<Language> graph = DependencyGraph();
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
    graph.setSuccessors(current, currentChildren);
    if (transient[current] != newProperty) {
      transient[current] = newProperty;
      //signal the parents because the current language nullability changed
      graph.predecessors(current).forEach((observer) {
        graph.clearSuccessors(observer);
        workset.add(observer);
      });
    }
  }
}
