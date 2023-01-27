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

  get isEmpty => this == empty;

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
  const Empty._create();
  static const Empty emptyI = Empty._create();
  factory Empty() => emptyI;

  @override
  Language derivative(Object token) => empty;

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
  const Epsilon._create();
  static const Epsilon epsI = Epsilon._create();
  factory Epsilon() => epsI;

  @override
  Language derivative(Object token) => empty;

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
  Language derivative(Object token) => this.token == token ? eps() : empty;

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
}

/// A composite parser encapsulates at least another parser
abstract class Composite extends Language {}

class Union extends Composite {
  Union(this.lhs, this.rhs);
  final Language lhs, rhs;
  @override
  Language derivative(Object token) =>
      lhs.derivative(token) | rhs.derivative(token);

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
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  final Language lhs, rhs;
  @override
  Language derivative(Object token) =>
      lhs.delta.seq(rhs.derivative(token)) | lhs.derivative(token).seq(rhs);

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
}

class Delta extends Composite {
  Delta(this.operand);
  final Language operand;
  @override
  Language derivative(Object token) => empty;

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
}

class Reference extends Composite {
  Reference(this.name, [this.target = Empty.emptyI]);
  final String name;
  Language target;
  set setTarget(Language target) {
    this.target = target;
  }

  Delayed? _delayed;
  bool? _isNullable;
  bool? _isProductive;
  int? _hashCode;

  @override
  Language derivative(Object token) {
    if (_delayed != null) {
      return _delayed!;
    }
    _delayed = target.delayed() as Delayed;

    var d = _delayed!.force(token);
    return d;
  }

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
}

class Delayed extends Language {
  Delayed(this.operand);
  final Language operand;

  ///need memoization
  @override
  Language derivative(Object token) {
    return force(token);
  }

  ///needs fixed point & memoization
  ///the idea is suppose false, and see if we can get through by traversing the forced language
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
}
