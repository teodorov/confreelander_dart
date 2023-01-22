import 'package:collection/collection.dart';
import 'package:confreelander/confreelander.dart';
import 'smart_constructors.dart';

abstract class Language {
  const Language();

  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable;
    return derivative(it.current).includes(it);
  }

  ///A isNullable language accepts the empty word.
  ///A word is included in a language if the last derivative in the series isNullable.
  ///So if not nullable then no parseTree.
  Set parse(Iterator it) {
    if (!it.moveNext()) return isNullable ? parseTrees() : {};
    return derivative(it.current).parse(it);
  }

  get isEmpty => this == empty;

  Language derivative(Object token);
  Set parseTrees();
  bool get isNullable;
  bool get isProductive => false;
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

  //incomplete parse, the set of parse trees is empty
  @override
  Set parseTrees() => {};

  @override
  bool get isNullable => false;

  @override
  String toString() => '∅';
}

class Epsilon extends Terminal {
  final Set trees = {};

  Epsilon() {
    trees.add(Empty());
  }
  Epsilon.token(Object token) {
    trees.add(token);
  }
  Epsilon.trees(Set trees) {
    this.trees.addAll(trees);
  }

  @override
  Language derivative(Object token) => empty;

  //a complete parse, return the set of parse trees
  @override
  Set parseTrees() => trees;

  @override
  bool get isNullable => true;
  @override
  bool get isProductive => true;

  @override
  String toString() => 'ε$trees';

  @override
  int get hashCode =>
      Object.hash(runtimeType, DeepCollectionEquality().hash(trees));

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Epsilon &&
            DeepCollectionEquality().equals(trees, other.trees));
  }
}

class Token extends Terminal {
  Token(this.token);
  final Object token;
  @override
  Language derivative(Object token) =>
      this.token == token ? epsToken(this.token) : empty;

  //incomplete parse, the set of parse trees is empty
  @override
  Set parseTrees() => {};

  @override
  bool get isNullable => false;
  @override
  bool get isProductive => true;

  @override
  String toString() => 'Token($token)';

  @override
  int get hashCode => Object.hash(runtimeType, token);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Token && token == other.token);
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

  //union the results from their children
  @override
  Set parseTrees() => lhs.parseTrees().union(rhs.parseTrees());

  @override
  bool get isNullable => lhs.isNullable || rhs.isNullable;
  @override
  bool get isProductive => lhs.isProductive || rhs.isProductive;
  @override
  String toString() => '$lhs | $rhs';

  @override
  int get hashCode => Object.hash(runtimeType, lhs, rhs);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Union && lhs == other.lhs && rhs == other.rhs);
  }
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  final Language lhs, rhs;
  @override
  Language derivative(Object token) =>
      lhs.delta.seq(rhs.derivative(token)) | lhs.derivative(token).seq(rhs);

  //Concatenation nodes construct pairs of elements from their children
  @override
  Set parseTrees() {
    Set lhsTrees = lhs.parseTrees();
    Set rhsTrees = lhs.parseTrees();

    Set result = {};
    for (var lhsTree in lhsTrees) {
      for (var rhsTree in rhsTrees) {
        result.add([lhsTree, rhsTree]);
      }
    }
    return result;
  }

  @override
  bool get isNullable => lhs.isNullable && rhs.isNullable;
  @override
  bool get isProductive => lhs.isProductive && rhs.isProductive;
  @override
  String toString() => '$lhs ∘ $rhs';

  @override
  int get hashCode {
    return Object.hash(runtimeType, lhs, rhs);
  }

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Concatenation && lhs == other.lhs && rhs == other.rhs);
  }
}

class Star extends Composite {
  Star(this.operand);
  final Language operand;
  @override
  Language derivative(Object token) => operand.derivative(token).seq(operand);

  @override
  Set parseTrees() => {null};

  @override
  bool get isNullable => true;
  @override
  bool get isProductive => true;

  @override
  String toString() => '$operand*';

  @override
  int get hashCode => Object.hash(runtimeType, operand);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Star && operand == other.operand);
  }
}

class Delta extends Composite {
  Delta(this.operand);
  final Language operand;
  @override
  Language derivative(Object token) => empty;

  @override
  Set parseTrees() => operand.parseTrees();

  @override
  bool get isNullable => operand.isNullable;
  @override
  bool get isProductive => operand.isProductive;

  @override
  String toString() => 'δ($operand)';

  @override
  int get hashCode => Object.hash(runtimeType, operand);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Delta && operand == other.operand);
  }
}

class Projection extends Composite {
  Projection(this.operand, this.projector);
  final Language operand;
  final Function projector;
  @override
  Language derivative(Object token) => operand.derivative(token) >> projector;

  //Projections apply their function to the result of their child
  @override
  Set parseTrees() =>
      operand.parseTrees().fold({}, (pV, tree) => pV.union(projector(tree)));

  @override
  bool get isNullable => operand.isNullable;
  @override
  bool get isProductive => operand.isProductive;

  @override
  String toString() => '$operand >> $projector';

  //NB: cannot rely on dart function equality
  @override
  int get hashCode => Object.hash(runtimeType, operand, projector);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Projection &&
            operand == other.operand &&
            projector == other.projector);
  }
}

class Reference extends Composite {
  Reference(this.name, [this.target = Empty.emptyI]);
  final String name;
  Language target;
  set setTarget(Language target) {
    this.target = target;
  }

  Language? _derivative;
  Object? _token;
  Set? cachedParseTrees;
  bool? _isNullable;
  bool? _isProductive;
  int? _hashCode;

  ///needs memoization since D S = D S
  ///memoize just one derivative and one token
  @override
  Language derivative(Object token) {
    if (_token != null && _token == token && _derivative != null) {
      return _derivative!;
    }
    _token = token;
    _derivative = Delayed(target, token);
    return _derivative!;
  }

  @override
  Set parseTrees() => cachedParseTrees ??= target.parseTrees();

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
  String toString() => 'ref($name)';

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
}

class Delayed extends Language {
  Delayed(this.operand, this.token);
  final Language operand;
  final Object token;
  Language? _forcedLanguage;
  Language? _derivative;
  Object? _token;
  bool? _isNullable;
  bool? _isProductive;

  ///need memoization
  @override
  Language derivative(Object token) {
    if (_token != null && _token == token && _derivative != null) {
       return _derivative!;
    }
    _token = token;
    return _derivative = _forcedLanguage != null ? Delayed(_forcedLanguage!, token) : Delayed(this, token);
  }

  @override
  Set parseTrees() => force().parseTrees();

  ///needs fixed point & memoization
  ///the idea is suppose false, and see if we can get through by traversing the forced language
  @override
  bool get isNullable => _isNullable ??= _computeIsNullable();
  bool _computeIsNullable() {
    //suppose false, before traversing children
    _isNullable = false;
    var result = force().isNullable;
    //clear the cache
    _isNullable = null;
    return result;
  }

  @override
  bool get isProductive => _isProductive ??= _computeIsProductive();
  bool _computeIsProductive() {
    //suppose false, before traversing children
    _isProductive = false;
    var result = force().isProductive;
    //clear the cache
    _isProductive = null;
    return result;
  }

  @override
  String toString() => 'delayed($operand, $token)';

  Language force() {
    if (_forcedLanguage != null) return _forcedLanguage!;
    if (operand is Delayed) {
      var forcedOperand = (operand as Delayed).force();
      return _forcedLanguage = forcedOperand.derivative(token);
    }
    return _forcedLanguage = operand.derivative(token);
  }

  @override
  int get hashCode => Object.hash(runtimeType, operand, token);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Delayed && operand == other.operand && token == other.token);
  }
}
