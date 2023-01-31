import 'stupid_constructors.dart';

class FunctionalVisitor<I, O> {
  O visitLanguage(Language node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitTerminal(Terminal node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitEmpty(Empty node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitEpsilon(Epsilon node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitToken(Token node, I input) =>
      throw UnimplementedError('missing visitor method');

  O visitComposite(Composite node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitUnion(Union node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitConcatenation(Concatenation node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitDelta(Delta node, I input) =>
      throw UnimplementedError('missing visitor method');
  O visitReference(Reference node, I input) =>
      throw UnimplementedError('missing visitor method');
}

abstract class Language {
  const Language();

  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitLanguage(this, input);
  }

  get isEmpty => this == empty();
}

/// a Terminal parser does not contain sub-parsers
abstract class Terminal extends Language {
  const Terminal();
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitTerminal(this, input);
  }
}

class Empty extends Terminal {
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitEmpty(this, input);
  }

  @override
  String toString() => '∅';
}

class Epsilon extends Terminal {
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitEpsilon(this, input);
  }

  @override
  String toString() => 'ε';
}

class Token extends Terminal {
  Token(this.token);
  final Object token;
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitToken(this, input);
  }

  @override
  String toString() => '(Token $token)';
}

/// A composite parser encapsulates at least another parser
abstract class Composite extends Language {
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitComposite(this, input);
  }
}

class Union extends Composite {
  Union(this.lhs, this.rhs);
  final Language lhs, rhs;

  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitUnion(this, input);
  }

  @override
  String toString() => '($lhs | $rhs)';
}

class Concatenation extends Composite {
  Concatenation(this.lhs, this.rhs);
  final Language lhs, rhs;

  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitConcatenation(this, input);
  }

  @override
  String toString() => '($lhs ∘ $rhs)';
}

class Delta extends Composite {
  Delta(this.operand);
  final Language operand;
  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitDelta(this, input);
  }

  @override
  String toString() => '(δ $operand)';
}

class Reference extends Composite {
  Reference(this.name);
  final Object name;
  Language target = empty();

  @override
  O accept<I, O>(FunctionalVisitor<I, O> visitor, input) {
    return visitor.visitReference(this, input);
  }

  @override
  String toString() => '(ref $name)';
}
