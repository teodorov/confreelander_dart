import 'dart:collection';
import 'stupid_constructors.dart';

abstract class Language {
  const Language();

  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable;
    var der = derivative(it.current);
    if (!der.isNullable) return false;
    return der.includes(it);
  }

  get isEmpty => this == empty();

  Language derivative(Object token) {
    var start = Queue<Language>();
    var visited = Queue<Map<Language, Language>>();
    start.add(this);
    visited.add({});
    derivate(token, start, visited);
    return visited.last[this]!;
  }

  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited);

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

  Iterable<Language> operands();
}

/// a Terminal parser does not contain sub-parsers
abstract class Terminal extends Language {
  const Terminal();
}

class Empty extends Terminal {
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

  @override
  Iterable<Language> operands() {
    return {};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    visited.last[this] = empty();
  }
}

class Epsilon extends Terminal {
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

  @override
  Iterable<Language> operands() {
    return {};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    visited.last[this] = empty();
  }
}

class Token extends Terminal {
  Token(this.token);
  final Object token;

  @override
  bool get isNullable => false;
  @override
  bool get isProductive => true;

  @override
  String toString() => '(Token $token)';

  @override
  int get hashCode => Object.hash(runtimeType, token);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Token && token == other.token);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} T($token)';
    return '';
  }

  @override
  Iterable<Language> operands() {
    return {};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    visited.last[this] = this.token == token ? eps() : empty();
  }
}

/// A composite parser encapsulates at least another parser
abstract class Composite extends Language {}

class Union extends Composite {
  Union(this.lhs, this.rhs);
  final Language lhs, rhs;

  @override
  bool get isNullable => lhs.isNullable || rhs.isNullable;
  @override
  bool get isProductive => lhs.isProductive || rhs.isProductive;
  @override
  String toString() => '($lhs | $rhs)';

  @override
  int get hashCode => Object.hash(runtimeType, lhs, rhs);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Union && lhs == other.lhs && rhs == other.rhs);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} |';
    var lhsL = lhs.computeTGF(map);
    var rhsL = rhs.computeTGF(map);
    return '$lhsL\n$rhsL\n${identityHashCode(this)} ${identityHashCode(lhs)}\n${identityHashCode(this)} ${identityHashCode(rhs)}\n';
  }

  @override
  Iterable<Language> operands() {
    return {lhs, rhs};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    lhs.derivate(token, start, visited);
    rhs.derivate(token, start, visited);
    visited.last[this] = visited.last[lhs]! | visited.last[rhs]!;
  }
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  final Language lhs, rhs;

  @override
  bool get isNullable => lhs.isNullable && rhs.isNullable;
  @override
  bool get isProductive => lhs.isProductive && rhs.isProductive;
  @override
  String toString() => '($lhs ∘ $rhs)';

  @override
  int get hashCode {
    return Object.hash(runtimeType, lhs, rhs);
  }

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Concatenation && lhs == other.lhs && rhs == other.rhs);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} ∘';
    var lhsL = lhs.computeTGF(map);
    var rhsL = rhs.computeTGF(map);
    return '$lhsL\n$rhsL\n${identityHashCode(this)} ${identityHashCode(lhs)}\n${identityHashCode(this)} ${identityHashCode(rhs)}\n';
  }

  @override
  Iterable<Language> operands() {
    return {lhs, rhs};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    lhs.derivate(token, start, visited);
    rhs.derivate(token, start, visited);
    var dlhs = visited.last[lhs]!;
    var drhs = visited.last[rhs]!;
    visited.last[this] = lhs.delta.seq(drhs) | dlhs.seq(rhs);
  }
}

class Delta extends Composite {
  Delta(this.operand);
  final Language operand;

  @override
  bool get isNullable => operand.isNullable;
  @override
  bool get isProductive => operand.isProductive;

  @override
  String toString() => '(δ $operand)';

  @override
  int get hashCode => Object.hash(runtimeType, operand);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Delta && operand == other.operand);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} δ';
    var opL = operand.computeTGF(map);
    return '$opL\n${identityHashCode(this)} ${identityHashCode(operand)}\n';
  }

  @override
  Iterable<Language> operands() {
    return {operand};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    visited.last[this] = empty();
  }
}

class Reference extends Composite {
  Reference(this.name);
  final String name;
  Language target = empty();
  set setTarget(Language target) {
    this.target = target;
  }

  Delayed? _delayed;
  bool? _isNullable;
  bool? _isProductive;
  int? _hashCode;

  ///needs fixed point & memoization
  ///the idea is suppose false, and see if we can get through by traversing the target
  @override
  bool get isNullable => _isNullable ??= _computeIsNullable();
  bool _computeIsNullable() {
    //suppose false, before traversing children
    _isNullable = false;
    var result = target.isNullable;
    //clear the cache
    _isNullable = null;
    return result;
  }

  @override
  bool get isProductive => _isProductive ??= _computeIsProductive();
  bool _computeIsProductive() {
    //suppose false, before traversing children
    _isProductive = false;
    var result = target.isProductive;
    //clear the cache
    _isProductive = null;
    return result;
  }

  @override
  String toString() => '(ref $name)';

  //we cannot get fixedpoint here, because the ints are not a lattice
  //but a hash based on the name and the target language hash should be good enough
  @override
  int get hashCode => _hashCode ??= _computeHashCode();
  int _computeHashCode() {
    //the seed value
    _hashCode = Object.hash(runtimeType, name);
    //traverse children
    var hash = target.hashCode;
    //integrate children hashcode
    var result = Object.hash(runtimeType, name, hash);
    //clear the cache
    _hashCode = null;
    return result;
  }

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Reference && name == other.name && target == other.target);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} R($name)';
    var targetL = target.computeTGF(map);
    return '$targetL\n${identityHashCode(this)} ${identityHashCode(target)}\n';
  }

  @override
  Iterable<Language> operands() {
    return {target};
  }

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    if (start.last == this) {
      if (visited.last[this] == null) {
        start.add(this);
        visited.add({this: target.delayed()});
        target.derivate(token, start, visited);
        return;
      }
      var dTarget = visited.last[target]!;
      start.removeLast();
      visited.removeLast();
      visited.last[target] = dTarget;
      return;
    }
    if (visited.last[this] != null) {
      return;
    }
    visited.last[this] = target.delayed();
    target.derivate(token, start, visited);
    visited.last[this] = visited.last[target]!;
  }
}

class Delayed extends Language {
  Delayed(this.operand);
  final Language operand;

  @override
  void derivate(Object token, Queue<Language> start,
      Queue<Map<Language, Language>> visited) {
    operand.derivate(token, start, visited);
    visited.last[this] = visited.last[operand]!;
  }

  @override
  bool get isNullable => false;

  @override
  bool get isProductive => false;

  @override
  String toString() => '(delayed $operand $token)';

  Language force(Object token) {
    return operand.derivative(token);
  }

  @override
  int get hashCode => Object.hash(runtimeType, operand, token);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Delayed && operand == other.operand);
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} Δ';
    var opL = operand.computeTGF(map);
    return '$opL\n${identityHashCode(this)} ${identityHashCode(operand)}\n';
  }

  @override
  Iterable<Language> operands() {
    return {operand};
  }
}
