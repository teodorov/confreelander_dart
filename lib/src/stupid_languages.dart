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

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Empty;
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

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Epsilon;
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
  Language derivative(Object token) => empty();
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
  Reference(this.name);
  final Object name;
  Language target = empty();
  set setTarget(Language target) {
    this.target = target;
  }

  Reference? _derivative;
  bool? _isNullable;
  bool? _isProductive;
  int? _hashCode;

  ///needs fixed point & memoization
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
    _derivative!.target = target.derivative(token);
    var der = _derivative!;
    //reset the derivative for the next time
    _derivative = null;
    return der;
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
    if (super == other) return true;
    if (other is! Reference) return false;
    if (name != other.name) return false;
    return target == other.target;
  }

  @override
  String computeTGF(Map<Language, String> map) {
    if (map[this] != null) return '';
    map[this] = '${identityHashCode(this)} R($name)';
    var targetL = target.computeTGF(map);
    return '$targetL\n${identityHashCode(this)} ${identityHashCode(target)}\n';
  }
}
