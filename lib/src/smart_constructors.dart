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
ref(Language o) => o == empty ? empty : Reference(o);

extension SmartConstructors on Language {
  empty() => Empty();

  eps() => Epsilon();

  epsToken(Object token) => Epsilon.token(token);

  epsTrees(Set trees) {
    if (trees.isEmpty) return empty();
    if (trees.length == 1 && trees.contains(empty())) return empty();
    return Epsilon.trees(trees);
  }

  token(Object o) => Token(o);

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
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
