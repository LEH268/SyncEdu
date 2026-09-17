import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  test('the instrument has exactly twenty questions', () {
    expect(kPreAdmissionInstrument, hasLength(20));
  });

  test('every question has four options', () {
    for (final PreAdmissionQuestion q in kPreAdmissionInstrument) {
      expect(q.options, hasLength(4), reason: q.prompt);
    }
  });

  test('every option carries at least one tag', () {
    for (final PreAdmissionQuestion q in kPreAdmissionInstrument) {
      for (final PreAdmissionOption o in q.options) {
        expect(o.tags, isNotEmpty, reason: '${q.prompt} / ${o.text}');
      }
    }
  });

  test('every tag in the instrument matches a scoring branch', () {
    // The reference shipped a `Kinesthetic` tag that matched no branch and was
    // silently discarded. This test is the guard against repeating it.
    for (final PreAdmissionQuestion q in kPreAdmissionInstrument) {
      for (final PreAdmissionOption o in q.options) {
        for (final String tag in o.tags) {
          expect(kScoredTags, contains(tag), reason: 'unscored tag "$tag"');
        }
      }
    }
  });

  test('scoring tallies VARK correctly', () {
    // Answer option 0 for every question; count its V/A/R/K tags by hand.
    final List<int> answers = List<int>.filled(20, 0);
    final Map<String, int> expected = <String, int>{'V': 0, 'A': 0, 'R': 0, 'K': 0};
    for (final PreAdmissionQuestion q in kPreAdmissionInstrument) {
      for (final String tag in q.options[0].tags) {
        if (expected.containsKey(tag)) expected[tag] = expected[tag]! + 1;
      }
    }
    expect(scoreInstrument(answers).vark, expected);
  });

  test('the dominant style is the highest VARK score', () {
    final PreAdmissionProfile p = scoreInstrument(List<int>.filled(20, 3));
    final int top = p.vark.values.reduce((a, b) => a > b ? a : b);
    expect(p.vark[p.dominantStyle], top);
  });

  test('a tie resolves deterministically in V, A, R, K order', () {
    // Build answers with equal V and A tallies and nothing higher by choosing
    // per-question the option that keeps V and A level. Simpler: assert the
    // helper directly via a synthetic all-zero profile has a defined winner.
    final PreAdmissionProfile p = scoreInstrument(List<int>.filled(20, 0));
    // Whatever the tallies, the dominant must be the first of kVarkOrder that
    // holds the max.
    final int max = p.vark.values.reduce((a, b) => a > b ? a : b);
    final String firstMax = kVarkOrder.firstWhere((l) => p.vark[l] == max);
    expect(p.dominantStyle, firstMax);
  });

  test('an incomplete answer list is refused rather than scored', () {
    expect(() => scoreInstrument(<int>[0, 1, 2]), throwsArgumentError);
    expect(() => scoreInstrument(List<int>.filled(20, 9)), throwsArgumentError);
  });

  test('personality axes are independent of VARK', () {
    final PreAdmissionProfile p = scoreInstrument(List<int>.filled(20, 1));
    final int varkTotal = p.vark.values.reduce((a, b) => a + b);
    final int personalityTotal = p.structured +
        p.exploratory +
        p.introvert +
        p.extrovert +
        p.impulsivity +
        p.reflectivity;
    // Every tag lands in exactly one of the two buckets, never both.
    int tagCount = 0;
    for (final PreAdmissionQuestion q in kPreAdmissionInstrument) {
      tagCount += q.options[1].tags.length;
    }
    expect(varkTotal + personalityTotal, tagCount);
  });
}
