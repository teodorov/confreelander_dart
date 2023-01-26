import 'stupid_languages.dart';

Language empty = Empty();
Language eps() => Epsilon();

Language token(Object o) => Token(o);
Reference ref(String name) => Reference(name);

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

  Language delayed(Object token) {
    return Delayed(this, token);
  }

  Language ref(String name) => isEmpty ? empty : Reference(name, this);
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
