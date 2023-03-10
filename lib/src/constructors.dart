import 'package:confreelander/src/nullability.dart';

import 'languages.dart';

Language empty() => Empty();
Language eps() => Epsilon();

Language token(Object o) => Token(o);
Reference ref(Object name) => Reference(name);

bool smartConstructors = true;

extension SmartConstructors on Language {
  Language operator |(Language other) {
    if (smartConstructors) {
      // ∅ | p ⟹ p
      if (isEmpty) return other;
      // p | ∅ ⟹ p
      if (other.isEmpty) return this;
    }
    return Union(this, other);
  }

  Language concatenation(Language other) {
    if (smartConstructors) {
      // ∅ ∘ p ⟹ ∅
      // p ∘ ∅ ⟹ ∅
      if (isEmpty || other.isEmpty) return empty();
    }
    return Concatenation(this, other);
  }

  Language seq(Language other) {
    return concatenation(other);
  }

  Language get delta {
    /// For recognition there is no need for the delta node.
    // return isNullable ? eps() : empty();
    /// Delta cannot be simplified to eps() when parsing, we need the tokens associated
    // Δ Δ p          = Δ p
    return (this is Delta) ? this : Delta(this);
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
