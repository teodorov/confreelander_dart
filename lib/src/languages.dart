import 'package:collection/collection.dart';
import 'package:confreelander/confreelander.dart';
import 'smart_constructors.dart';

abstract class Language {
  const Language();

  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable;
    return derive(it.current).includes(it);
  }

  Set parse(Iterator it) {
    if (!it.moveNext()) return parseTrees();
    return derive(it.current).parse(it);
  }

  get isEmpty => this == empty;

  Language derive(Object token);
  Set parseTrees();
  bool get isNullable;
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
  Language derive(Object token) => empty;

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
  Language derive(Object token) => empty;

  //a complete parse, return the set of parse trees
  @override
  Set parseTrees() => trees;

  @override
  bool get isNullable => true;

  @override
  String toString() => 'ε';

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
  Language derive(Object token) =>
      this.token == token ? epsToken(this.token) : empty;

  //incomplete parse, the set of parse trees is empty
  @override
  Set parseTrees() => {};

  @override
  bool get isNullable => false;

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
  Language derive(Object token) => lhs.derive(token) | rhs.derive(token);

  //union the results from their children
  @override
  Set parseTrees() => lhs.parseTrees().union(rhs.parseTrees());

  @override
  bool get isNullable => lhs.isNullable || rhs.isNullable;

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
  Language derive(Object token) =>
      lhs.delta.seq(rhs.derive(token)) | lhs.derive(token).seq(rhs);

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
  Language derive(Object token) => operand.derive(token).seq(operand);

  @override
  Set parseTrees() => {null};

  @override
  bool get isNullable => true;

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
  Language derive(Object token) => empty;

  @override
  Set parseTrees() => operand.parseTrees();

  @override
  bool get isNullable => operand.isNullable;

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
  Language derive(Object token) => operand.derive(token) >> projector;

  //Projections apply their function to the result of their child
  @override
  Set parseTrees() =>
      operand.parseTrees().fold({}, (pV, tree) => pV.union(projector(tree)));

  @override
  bool get isNullable => operand.isNullable;

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

  Language? cachedDerivative;
  Object? cachedToken;
  Set? cachedParseTrees;
  bool? cachedIsNullable;
  int? cachedHashCode;

  @override
  Language derive(Object token) {
    return Delayed(target, token);
  }

  @override
  Set parseTrees() => cachedParseTrees ??= target.parseTrees();

  @override
  bool get isNullable {
    if (cachedIsNullable != null) return cachedIsNullable!;
    cachedIsNullable = false;

    cachedIsNullable = target.isNullable;
    return cachedIsNullable!;
  }

  @override
  String toString() => 'ref($name)';

  @override
  int get hashCode {
    if (cachedHashCode != null) return cachedHashCode!;
    cachedHashCode = Object.hash(runtimeType, name);
    var hash = target.hashCode;
    cachedHashCode = Object.hash(cachedHashCode!, hash);
    return cachedHashCode!;
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
  Language? derivative;

  @override
  Language derive(Object token) => derivative ?? Delayed(this, token);

  @override
  Set parseTrees() => force().parseTrees();

  @override
  bool get isNullable => force().isNullable;

  @override
  String toString() => 'delayed($operand, $token)';

  Language force() {
    if (derivative != null) return derivative!;
    if (operand is Delayed) {
      var operandDerivative = (operand as Delayed).force();
      return derivative = operandDerivative.derive(token);
    }
    return derivative = operand.derive(token);
  }

  @override
  int get hashCode => Object.hash(runtimeType, operand, token);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Delayed && operand == other.operand && token == other.token);
  }
}
