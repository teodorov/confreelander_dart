import 'stupid_languages.dart';

Language empty() => Empty();
Language eps() => Epsilon();

Language token(Object o) => Token(o);
Reference ref(Object name) => Reference(name);

/// The StupidConstructors extension does not implement the simplification rules

extension SmartConstructors on Language {
  Language operator |(Language other) {
    return Union(this, other);
  }

  Language concatenation(Language other) {
    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get delta => Delta(this);

  Language delayed() {
    return Delayed(this);
  }

  Language ref(Object name) {
    if (isEmpty) return empty();
    var r = Reference(name);
    r.target = this;
    return r;
  }
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
