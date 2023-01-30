import 'package:confreelander/src/derivative.dart';

import 'stupid_languages.dart';

extension DerivativesAreIterable on Language {
  Iterable<Language> derivatives(Iterable<Object> it) {
    return DerivativeIterable(this, it);
  }
}

class DerivativeIterable extends Iterable<Language> {
  DerivativeIterable(this.language, this.iterable);
  Language language;
  Iterable iterable;
  @override
  Iterator<Language> get iterator =>
      DerivativeIterator(language, iterable.iterator);
}

class DerivativeIterator extends Iterator<Language> {
  DerivativeIterator(this.currentLanguage, this.wordIterator);
  Language currentLanguage;
  final Iterator wordIterator;
  @override
  Language get current => currentLanguage;

  @override
  bool moveNext() {
    if (!wordIterator.moveNext()) return false;
    currentLanguage = currentLanguage.derivative(wordIterator.current);
    return true;
  }
}
