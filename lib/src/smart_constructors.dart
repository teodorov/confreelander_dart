import 'languages.dart';

Language empty = Empty();
Language eps() => Epsilon();

Language epsToken(Object token) => Epsilon.token(token);

Language epsTrees(Set trees) {
  if (trees.isEmpty) return empty;
  if (trees.length == 1 && trees.contains(empty)) return empty;
  return Epsilon.trees(trees);
}

Language token(Object o) => Token(o);
Language ref(Language o) => o == empty ? empty : Reference(o);

extension SmartConstructors on Language {
  Language operator |(Language other) {
    if (isEmpty) return other;
    if (other.isEmpty) return this;
    return Union(this, other);
  }

  Language concatenation(Language other) {
    if (isEmpty || other.isEmpty) return empty;
    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get star => this is Star ? this : Star(this);

  Language get delta => Delta(this);

  Language operator >>(Function projector) => Projection(this, projector);

  Language get ref => Reference(this);
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
