import 'stupid_languages.dart';

Language empty() => Empty();
Language eps() => Epsilon();

Language token(Object o) => Token(o);
Reference ref(String name) => Reference(name);

/// The SmartConstructors extension implements the following rules:
/// ∅ | p ⟹ p
/// p | ∅ ⟹ p
///
/// ∅ ∘ p ⟹ ∅
/// p ∘ ∅ ⟹ ∅
///
/// delayed(ϵ,t) ⟹ ∅
/// delayed(delayed(L, t₀), t₁) ⟹ delayed(L, t₀)
///                 where delayed(L, t₀) == delayed(L, t₀).forced && t₀ == t₁

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
    if (isEmpty || other.isEmpty) return empty();

    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get delta => Delta(this);

  Language delayed() {
    ///delayed(ϵ,t) ⟹ ∅
    // if (this is Epsilon) {
    //   return empty;
    // }
    // if (this is Delayed) {
    //   Delayed thisAsDelay = this as Delayed;

    //   /// delayed(delayed(L, t₀), t₁) ⟹ delayed(L, t₀)
    //   ///                where delayed(L, t₀) == delayed(L, t₀).forced && t₀ == t₁
    //   if (this == thisAsDelay.force() && thisAsDelay.token == token) {
    //     return this;
    //   }
    //   //delayed(delayed(L, t₀), t₁) ⟹ delayed(delayed(L, t₀).forced, t₁)
    //   // return Delayed((this as Delayed).force(), token);
    // }
    return Delayed(this);
  }

  Language ref(String name) {
    if (isEmpty) return empty();
    var r = Reference(name);
    r.target = this;
    return r;
  }
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
