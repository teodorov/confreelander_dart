import 'package:confreelander/src/smart_constructors.dart';
import 'package:confreelander/src/smart_languages.dart';
import 'package:test/test.dart';

void main() {
  group('smart constructors', () {
    test(
        'delayed(delayed(L, t₀), t₁) ⟹ delayed(L, t₀), a == a.force && t₀ == t₁',
        () {
      print('\n-----ddfX----\n');
      var rx = ref('x');
      var x = token('a') | rx;
      rx.target = x;
      Language a = (eps() | x.delayed('a')).delayed('a');
      // File('delayedX.tgf').writeAsStringSync((a).toTGF());
      // File('delayedXf.tgf').writeAsStringSync(((a as Delayed).force()).toTGF());
      // File('delayedXfd.tgf').writeAsStringSync(a.derivative('a').toTGF());
      // File('delayedXfdd.tgf')
      //     .writeAsStringSync(a.derivative('a').derivative('a').toTGF());
      expect((a as Delayed), a.force());
      expect(a.delayed('a'), a);
    });

    test('delayed(D(X = X, a), a) = delayed(X = X, a)', () {
      print('\n-----ddfX----\n');
      var rx = ref('x');
      rx.target = rx;
      Language a = rx.derivative('a');

      expect(a.delayed('a'), a);
    });
  });
}
