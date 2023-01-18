import 'package:collection/collection.dart';

abstract class Language {
  const Language();
  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable();
    return derive(it.current).includes(it);
  }

  Set parse(Iterator it) {
    if (!it.moveNext()) return parseTrees();
    return derive(it.current).parse(it);
  }

  get isEmpty => this == Empty();

  Language derive(Object token);
  Set parseTrees();
  bool isNullable();
}

/// a Terminal parser does not contain sub-parsers
abstract class Terminal extends Language {
  const Terminal();
}

class Empty extends Terminal {
  const Empty._create();
  static final Empty emptyI = Empty._create();
  factory Empty() => emptyI;

  @override
  Language derive(Object token) => Empty();

  @override
  Set parseTrees() => {};

  @override
  bool isNullable() => false;

  @override
  String toString() => '∅';
}

class Epsilon extends Terminal {
  Set trees = {};

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
  Language derive(Object token) => Empty();

  @override
  Set parseTrees() => trees;

  @override
  bool isNullable() => true;

  @override
  String toString() => 'ε';

  @override
  int get hashCode => Object.hash(runtimeType, SetEquality().hash(trees));

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Epsilon && SetEquality().equals(trees, other.trees));
  }
}

class Token extends Terminal {
  Token(this.token);
  Object token;
  @override
  Language derive(Object token) =>
      this.token == token ? Epsilon.token(this.token) : Empty();

  @override
  Set parseTrees() => {};

  @override
  bool isNullable() => false;

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
abstract class Composite extends Language {
  xderive(Object token);
  xparseTrees();
  xisNullable();

  @override
  Language derive(Object token) {
    return xderive(token);
  }

  @override
  Set parseTrees() {
    return xparseTrees();
  }

  @override
  bool isNullable() {
    return xisNullable();
  }
}

class Union extends Composite {
  Union(this.lhs, this.rhs);
  Language lhs, rhs;
  @override
  Language xderive(Object token) => Union(lhs.derive(token), rhs.derive(token));

  @override
  Set xparseTrees() => lhs.parseTrees().union(rhs.parseTrees());

  @override
  bool xisNullable() => lhs.isNullable() || rhs.isNullable();

  @override
  String toString() => '$lhs | $rhs';

  @override
  int get hashCode => lhs.isEmpty
      ? rhs.hashCode
      : (rhs.isEmpty ? lhs.hashCode : Object.hash(runtimeType, lhs, rhs));

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Union && lhs == other.lhs && rhs == other.rhs) ||
        (lhs.isEmpty && rhs == other) ||
        (rhs.isEmpty && lhs == other);
  }
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  Language lhs, rhs;
  @override
  Language xderive(Object token) => Union(
      Concatenation(Delta(lhs), rhs.derive(token)),
      Concatenation(lhs.derive(token), rhs));

  @override
  Set xparseTrees() {
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
  bool xisNullable() => lhs.isNullable() && rhs.isNullable();

  @override
  String toString() => '$lhs ∘ $rhs';

  @override
  int get hashCode => lhs.isEmpty || rhs.isEmpty
      ? Empty().hashCode
      : Object.hash(runtimeType, lhs, rhs);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Concatenation && lhs == other.lhs && rhs == other.rhs) ||
        ((lhs.isEmpty || rhs.isEmpty) && (other as Language).isEmpty);
  }
}

class Star extends Composite {
  Star(this.operand);
  Language operand;
  @override
  Language xderive(Object token) =>
      Concatenation(operand.derive(token), operand);

  @override
  Set xparseTrees() => {null};

  @override
  bool xisNullable() => true;

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
  Language operand;
  @override
  Language xderive(Object token) => Empty();

  @override
  Set xparseTrees() => operand.parseTrees();

  @override
  bool xisNullable() => operand.isNullable();

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
  Language operand;
  Function projector;
  @override
  Language xderive(Object token) =>
      Projection(operand.derive(token), projector);

  @override
  Set xparseTrees() =>
      operand.parseTrees().fold({}, (pV, tree) => pV.union(projector(tree)));

  @override
  bool xisNullable() => operand.isNullable();

  @override
  String toString() => '$operand >> $projector';

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
  Reference(this.target);
  Language target;
  @override
  Language xderive(Object token) => target.derive(token);

  @override
  Set xparseTrees() => target.parseTrees();

  @override
  bool xisNullable() => target.isNullable();

  @override
  String toString() => 'ref($target)';

  @override
  int get hashCode => Object.hash(runtimeType, target);

  @override
  bool operator ==(Object other) {
    return super == other || (other is Reference && target == other.target);
  }
}

class Delayed extends Language {
  Delayed(this.operand, this.token);
  Language operand;
  Object token;

  @override
  Language derive(Object token) => force().derive(token);

  @override
  Set parseTrees() => force().parseTrees();

  @override
  bool isNullable() => force().isNullable();

  @override
  String toString() => 'delayed($operand, $token)';

  force() => operand.derive(token);

  @override
  int get hashCode => Object.hash(runtimeType, operand, token);

  @override
  bool operator ==(Object other) {
    return super == other ||
        (other is Delayed && operand == other.operand && token == other.token);
  }
}
