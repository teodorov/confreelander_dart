import 'dart:collection';

import 'package:confreelander/src/nullability.dart';
import 'package:confreelander/src/stupid_constructors.dart';
import 'package:confreelander/src/stupid_languages.dart';

extension Derivative on Language {
  bool includes(Iterator it) {
    if (!it.moveNext()) return isNullable;
    var der = derivative(it.current);
    return der.includes(it);
  }

  Language derivative(token) {
    return accept(LanguageDerivative(), token);
  }
}

class LanguageDerivative extends FunctionalVisitor<Object, Language> {
  Language derivative(node, token) {
    return node.accept(this, token);
  }

  @override
  Language visitEmpty(Empty node, Object input) => empty();
  @override
  Language visitEpsilon(Epsilon node, Object input) => empty();
  @override
  Language visitToken(Token node, Object input) =>
      node.token == input ? eps() : empty();

  @override
  Language visitUnion(Union node, Object input) =>
      derivative(node.lhs, input) | derivative(node.rhs, input);
  @override
  Language visitConcatenation(Concatenation node, Object input) =>
      node.lhs.delta.seq(derivative(node.rhs, input)) |
      derivative(node.lhs, input).seq(node.rhs);
  @override
  Language visitDelta(Delta node, Object input) => empty();
  Map<Reference, Reference> referenceDerivativeCache = HashMap.identity();
  @override
  Language visitReference(Reference node, Object input) {
    //check the cache
    var refDerivative = referenceDerivativeCache[node];
    if (refDerivative != null) return refDerivative;
    //the derivative is an empty reference
    refDerivative = referenceDerivativeCache[node] = ref(Object());
    //compute the derivative of the target
    refDerivative.target = derivative(node.target, input);
    return refDerivative;
  }
}
