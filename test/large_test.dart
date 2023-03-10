import "package:characters/characters.dart";
import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/constructors.dart';
import 'package:test/test.dart';

void main() {
  group('inclusion', () {
    it(String a) {
      return a.characters;
    }

    ///There exists an exponential number of different ways for (a*|b)* to match all the 'a's.
    test('(a*|b)*c', () {
      var rA = ref('A');
      var rG = ref('G');
      var pA = eps() | token('a').seq(rA);
      var pG = eps() | (rA | token('b')).seq(rG);
      var pT = rG.seq(token('c'));
      rA.target = pA;
      rG.target = pG;

      expect(pT.includes(it('a')), false);
      expect(pT.includes(it('ac')), true);
      expect(pT.includes(it('aa')), false);
      expect(pT.includes(it('aaaaa')), false);
      expect(pT.includes(it('aaaaac')), true);
      expect(pT.includes(it('aaaaaaaaa')), false);
    });
  });
}
