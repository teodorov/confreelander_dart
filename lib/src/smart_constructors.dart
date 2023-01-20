import 'languages.dart';

Language empty = Empty();
Language eps() => Epsilon();

Language epsToken(Object token) => Epsilon.token(token);

Language epsTrees(Set trees) {
  //if (trees.isEmpty) return empty;
  //if (trees.length == 1 && trees.contains(empty)) return empty;
  return Epsilon.trees(trees);
}

Language token(Object o) => Token(o);
Reference ref(String name) => Reference(name);

/// The SmartConstructors extension implements the following rules:
/// ∅ | p ⟹ p
/// p | ∅ ⟹ p
/// ϵₛ | ϵₜ ⟹ ϵ_{s ∪ t}
///
/// ∅ ∘ p ⟹ ∅
/// p ∘ ∅ ⟹ ∅
/// ϵₛ ∘ p ⟹ p >> λu.(s, u)
/// p ∘ ϵₛ ⟹ p >> λu.(u, s)
///
/// ∅* ⟹ ϵ_{∅}
/// p** ⟹ p*
///
/// ∅ >> f ⟹ ∅
/// ϵₛ >> f ⟹ ϵ_{s.map(λu.f(u))}
/// (ϵₛ ∘ p) >> f ⟹ p >> λu. f( (s, u) )
/// (p >> f) >> g ⟹ p >> (g ◯ f)

extension SmartConstructors on Language {
  Language operator |(Language other) {
    // ∅ | p ⟹ p
    if (isEmpty) return other;
    // p | ∅ ⟹ p
    if (other.isEmpty) return this;
    // ϵₛ | ϵₜ ⟹ ϵₛ ᵤ ₜ
    if (this is Epsilon && other is Epsilon) {
      return epsTrees({parseTrees(), other.parseTrees()});
    }
    return Union(this, other);
  }

  Language concatenation(Language other) {
    // ∅ ∘ p ⟹ ∅
    // p ∘ ∅ ⟹ ∅
    if (isEmpty || other.isEmpty) return empty;
    // ϵₛ ∘ p ⟹ p >> λu.(s, u)
    if (this is Epsilon) {
      return other >> (u) => [parseTrees(), u];
    }
    // p ∘ ϵₛ ⟹ p >> λu.(u, s)
    if (other is Epsilon) {
      return this >> (u) => [u, other.parseTrees()];
    }
    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get star {
    // ∅* ⟹ ϵ_{∅}
    if (isEmpty) return epsTrees({empty});
    // p** ⟹ p*
    return this is Star ? this : Star(this);
  }

  Language get delta => Delta(this);

  Language operator >>(Function projector) {
    // ∅ >> f ⟹ ∅
    if (isEmpty) return empty;
    // ϵₛ >> f ⟹ ϵ_{s.map(λu.f(u))}
    if (this is Epsilon) {
      return epsTrees(parseTrees().map((e) => projector(e)).toSet());
    }
    // (ϵₛ ∘ p) >> f ⟹ p >> λu. f( (s, u) )
    if (this is Concatenation && (this as Concatenation).lhs is Epsilon) {
      Epsilon lhs = (this as Concatenation).lhs as Epsilon;
      return (this as Concatenation).rhs >>
          (u) => projector([lhs.parseTrees(), u]);
    }
    // (p >> f) >> g ⟹ p >> (g ◯ f)
    if (this is Projection) {
      return (this as Projection).operand >>
          (x) => projector((this as Projection).projector(x));
    }
    return Projection(this, projector);
  }

  Language delayed(Object token) => Delayed(this, token);
  Language ref(String name) => isEmpty ? empty : Reference(name, this);
}

extension ConFreeLanDer on Object {
  toToken() => Token(this);
}
