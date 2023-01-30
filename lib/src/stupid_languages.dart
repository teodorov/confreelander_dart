import 'dart:collection';
import 'stupid_constructors.dart';

abstract class Language {
  const Language();

  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable;
    var der = derivative(it.current);
    return der.includes(it);
  }

  get isEmpty => this == empty();

  Language derivative(Object token);

  bool get isNullable;
  bool get isProductive => false;

  String computeTGF(Map<Language, String> map);
  toTGF() {
    Map<Language, String> nodeMap =
        HashMap(equals: identical, hashCode: identityHashCode);
    String links = computeTGF(nodeMap);
    String nodes = nodeMap.values.join('\n');
    return '0 0\n$nodes\n#\n0 ${identityHashCode(this)}\n$links';
  }
}

/// a Terminal parser does not contain sub-parsers
abstract class Terminal extends Language {
  const Terminal();
}

class Empty extends Terminal {
  @override
  Language derivative(Object token) => empty();

  @override
  bool get isNullable => false;

  @override
  String toString() => '∅';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} ∅';
    return '';
  }
}

class Epsilon extends Terminal {
  @override
  Language derivative(Object token) => empty();
  @override
  bool get isNullable => true;
  @override
  bool get isProductive => true;

  @override
  String toString() => 'ε';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} ϵ';
    return '';
  }
}

class Token extends Terminal {
  Token(this.token);
  final Object token;
  @override
  Language derivative(Object token) => this.token == token ? eps() : empty();
  @override
  bool get isNullable => false;
  @override
  bool get isProductive => true;

  @override
  String toString() => '(Token $token)';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} T($token)';
    return '';
  }
}

/// A composite parser encapsulates at least another parser
abstract class Composite extends Language {
  //begin for isNullable
  bool? transientNullability;
  bool? fixedNullability;
  List<Language> parents = [];
  static Queue<Language> workset = ListQueue();
  //end for isNullable

  @override
  bool get isNullable {
    if (fixedNullability != null) {
      return fixedNullability!;
    }
    //node_for
    ensureTransient(this);
    //workset.repeat solve
    while (workset.isNotEmpty) {
      var current = workset.removeFirst();
      solveNullability(current);
    }
    fixedNullability = transientNullability!;
    return fixedNullability!;
  }

  Composite ensureTransient(Composite node) {
    if (node.transientNullability != null) {
      return node;
    }
    node.transientNullability = false;
    workset.add(node);
    return node;
  }

  void solveNullability(Language current) {
    if (current is Terminal) return;
    Composite composite = current as Composite;
    if (composite.fixedNullability != null) return;
    bool nullableF(Language l) {
      if (l is Terminal) {
        return l.isNullable;
      }
      Composite node = l as Composite;
      if (node.fixedNullability != null) return node.fixedNullability!;
      node.parents.add(current);
      return ensureTransient(node).transientNullability!;
    }

    var newNullability = current.fixableIsNullable(nullableF);
    if (current.transientNullability != newNullability) {
      current.transientNullability = newNullability;
      //signal the parents because the current language nullability changed
      for (var element in current.parents) {
        workset.add(element);
      }
    }
  }

  fixableIsNullable(bool Function(Language l) isNullableF);
}

class Union extends Composite {
  Union(this.lhs, this.rhs);
  final Language lhs, rhs;

  @override
  Language derivative(Object token) =>
      lhs.derivative(token) | rhs.derivative(token);
  @override
  bool fixableIsNullable(bool Function(Language l) isNullableF) {
    return isNullableF(lhs) || isNullableF(rhs);
  }

  @override
  bool get isProductive => lhs.isProductive || rhs.isProductive;
  @override
  String toString() => '($lhs | $rhs)';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} |';
    var lhsL = lhs.computeTGF(map);
    var rhsL = rhs.computeTGF(map);
    return '$lhsL\n$rhsL\n${identityHashCode(this)} ${identityHashCode(lhs)} l\n${identityHashCode(this)} ${identityHashCode(rhs)} r\n';
  }
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  final Language lhs, rhs;
  @override
  Language derivative(Object token) =>
      lhs.derivative(token).seq(rhs) | lhs.delta.seq(rhs.derivative(token));
  @override
  bool fixableIsNullable(bool Function(Language l) isNullableF) {
    return isNullableF(lhs) && isNullableF(rhs);
  }

  @override
  bool get isProductive => lhs.isProductive && rhs.isProductive;
  @override
  String toString() => '($lhs ∘ $rhs)';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} ∘';
    var lhsL = lhs.computeTGF(map);
    var rhsL = rhs.computeTGF(map);
    return '$lhsL\n$rhsL\n${identityHashCode(this)} ${identityHashCode(lhs)} l\n${identityHashCode(this)} ${identityHashCode(rhs)} r\n';
  }
}

class Delta extends Composite {
  Delta(this.operand);
  final Language operand;
  @override
  Language derivative(Object token) => empty();
  @override
  bool fixableIsNullable(bool Function(Language l) isNullableF) {
    return isNullableF(operand);
  }

  @override
  bool get isProductive => operand.isProductive;

  @override
  String toString() => '(δ $operand)';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} δ';
    var opL = operand.computeTGF(map);
    return '$opL\n${identityHashCode(this)} ${identityHashCode(operand)}\n';
  }
}

class Reference extends Composite {
  Reference(this.name);
  final Object name;
  Language _target = empty();

  set target(Language target) {
    _target = target;
  }

  Reference? _derivative;
  bool? _isProductive;

  ///needs memoization
  ///the idea is
  ///   1. create an empty reference,
  ///   2. compute derivative of the target, obtaining the reference if recurse to this
  ///   3. set the reference target to the derivative of the target
  ///   4. clear the cache for the next time
  @override
  Language derivative(Object token) {
    if (_derivative != null) {
      return _derivative!;
    }
    //the the derivative to a reference
    _derivative = ref(Object());
    //recurse into the operand, and get its derivative
    _derivative!._target = _target.derivative(token);
    var der = _derivative!;
    //reset the derivative for the next time
    _derivative = null;
    return der;
  }

  @override
  bool fixableIsNullable(bool Function(Language l) isNullableF) {
    return isNullableF(_target);
  }

  @override
  bool get isProductive => _isProductive ??= _computeIsProductive();
  bool _computeIsProductive() {
    //suppose false, before traversing children
    _isProductive = false;
    var result = _target.isProductive;
    //clear the cache
    _isProductive = null;
    return result;
  }

  @override
  String toString() => '(ref $name)';

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} R($name)';
    var targetL = _target.computeTGF(map);
    return '$targetL\n${identityHashCode(this)} ${identityHashCode(_target)}\n';
  }
}
