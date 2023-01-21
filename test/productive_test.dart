import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('nullability', () {
    test('empty.isProductive', () {
      expect(empty.isProductive, false);
    });

    test('two refs isProductive', () {
      var rA = ref('A');
      var l = rA | token('x');
      rA.target = l;
      var l1 = rA;

      expect(rA.isProductive, true);
      expect(l.isProductive, true);
      expect(l1.isProductive, true);
    });
  });
}
