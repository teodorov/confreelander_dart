import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:characters/characters.dart';
import 'package:confreelander/src/constructors.dart';
import 'package:confreelander/src/derivative.dart';
import 'package:confreelander/src/languages.dart';

class LanguageInclusionBenchmark extends BenchmarkBase {
  LanguageInclusionBenchmark(name, this.language, this.word) : super('Language Inclusion $name');
  Language language;
  String word = 'a' * 300;

  // The benchmark code.
  @override
  void run() {
    language.includes(word.characters.iterator);
  }
}

Language nestedQuantifierLanguage() {
  var rA = ref('A');
  var rG = ref('G');
  var pA = eps() | token('a').seq(rA);
  var pG = eps() | (rA | token('b')).seq(rG);
  var pT = rG.seq(token('c'));
  rA.target = pA;
  rG.target = pG;
  return pT;
}

void main() {
  var language = nestedQuantifierLanguage();
  LanguageInclusionBenchmark('nested quantifiers  50 ko', language, 'a'*50).report();
  LanguageInclusionBenchmark('nested quantifiers 100 ko', language, 'a'*100).report();
  LanguageInclusionBenchmark('nested quantifiers 200 ko', language, 'a'*200).report();
  LanguageInclusionBenchmark('nested quantifiers 300 ko', language, 'a'*300).report();
  LanguageInclusionBenchmark('nested quantifiers  50 ok', language, '${'a'*50}c').report();

}
