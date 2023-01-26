import 'languages.dart';

Language empty = Empty();
Language eps() => Epsilon();

Language token(Object o) => Token(o);
Reference ref(String name) => Reference(name);

/// The SmartConstructors extension implements the following rules:
/// ∅ | p ⟹ p
/// p | ∅ ⟹ p
///
/// ∅ ∘ p ⟹ ∅
/// p ∘ ∅ ⟹ ∅

extension SmartConstructors on Language {
  Language operator |(Language other) {
    // ∅ | p ⟹ p
    if (isEmpty) return other;
    // p | ∅ ⟹ p
    if (other.isEmpty) return this;
    return Union(this, other);
  }

  Language concatenation(Language other) {
    // ∅ ∘ p ⟹ ∅
    // p ∘ ∅ ⟹ ∅
    if (isEmpty || other.isEmpty) return empty;

    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get delta => Delta(this);

  Language delayed(Object token) {
    if (this is Delayed) {
      return Delayed((this as Delayed).force(), token);
    }
    return Delayed(this, token);
  }

  Language ref(String name) => isEmpty ? empty : Reference(name, this);
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
