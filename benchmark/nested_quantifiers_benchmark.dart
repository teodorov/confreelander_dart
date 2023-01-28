import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:characters/characters.dart';
import 'package:confreelander/src/stupid_constructors.dart';
import 'package:confreelander/src/stupid_languages.dart';

class NestedQuantifierBenchmark extends BenchmarkBase {
  NestedQuantifierBenchmark() : super('NestedQuantifiers');
  static void main() {
    NestedQuantifierBenchmark().report();
  }

  it(String a) {
    return a.characters.iterator;
  }

  // The benchmark code.
  @override
  void run() {
    pT.includes(iterator);
  }

  late Language pT;
  late Iterator iterator;
  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    var rA = ref('A');
    var rG = ref('G');
    var pA = eps() | token('a').seq(rA);
    var pG = eps() | (rA | token('b')).seq(rG);
    pT = rG.seq(token('c'));
    rA.target = pA;
    rG.target = pG;

    iterator = it('aaaaaaaaa');
  }
}

void main() {
  NestedQuantifierBenchmark.main();
}
