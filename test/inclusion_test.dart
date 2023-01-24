import "package:characters/characters.dart";
import 'package:confreelander/confreelander.dart';
import 'package:test/test.dart';

void main() {
  group('derivative', () {
    test('mutually recursive', () {
      var rE = ref('E');
      var rS = ref('S');
      var e = token('e') | rS;
      var s = token('s') | rE;
      rE.target = e;
      rS.target = s;

      expect(e.includes('e'.characters.iterator), true);
      expect(e.includes('ee'.characters.iterator), true);
      expect(e.includes('eee'.characters.iterator), true);

      expect(e.includes('s'.characters.iterator), true);
      expect(e.includes('ss'.characters.iterator), true);
      expect(e.includes('sss'.characters.iterator), true);

      expect(e.includes('es'.characters.iterator), true);
      expect(e.includes('se'.characters.iterator), true);
      expect(e.includes('ees'.characters.iterator), true);
      expect(e.includes('ese'.characters.iterator), true);
      expect(e.includes('see'.characters.iterator), true);

      expect(e.includes('sse'.characters.iterator), true);
      expect(e.includes('ses'.characters.iterator), true);
      expect(e.includes('ess'.characters.iterator), true);
    });
  });
}
