abstract class Language {
  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable();
    return derive(it.current).includes(it);
  }

  Set parse(Iterator it) {
    if (!it.moveNext()) return parseTrees();
    return derive(it.current).parse(it);
  }

  empty() => Empty();

  eps() => Epsilon();

  epsToken(Object token) => Epsilon.token(token);

  epsTrees(Set trees) {
    if (trees.isEmpty) return empty();
    if (trees.length == 1 && trees.contains(empty())) return empty();
    return Epsilon.trees(trees);
  }

  tok(Object o) => Token(o);

  operator |(Language other) {
    if (this == empty()) return other;
    if (other == empty()) return this;
    return Union(this, other);
  }

  concatenation(Language other) {
    if (this == empty() || other == empty()) return empty();
    return Concatenation(this, other);
  }

  star() => this is Star ? this : Star(this);

  delta() => Delta(this);

  operator >>(Function projector) => Projection(this, projector);

  ref() => Reference(this);

  Language derive(Object token);
  Set parseTrees();
  bool isNullable();
}

/// a Terminal parser does not contain sub-parsers
abstract class Terminal extends Language {}

class Empty extends Terminal {
  Empty._create();
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
}

class Projection extends Composite {
  Projection(this.operand, this.projector);
  Language operand;
  Function projector;
  @override
  Language xderive(Object token) => operand.derive(token) >> projector;

  @override
  Set xparseTrees() =>
      operand.parseTrees().fold({}, (pV, tree) => pV.union(projector(tree)));

  @override
  bool xisNullable() => operand.isNullable();

  @override
  String toString() => '$operand >> $projector';
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
}
