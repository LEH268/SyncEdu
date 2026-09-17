import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  test('the composition is 40 academic, 30 student, 30 teacher', () {
    expect(composeFitScore(academicPct: 100, studentPct: 0, teacherPct: 0).score,
        closeTo(40, 0.01));
    expect(composeFitScore(academicPct: 0, studentPct: 100, teacherPct: 0).score,
        closeTo(30, 0.01));
    expect(composeFitScore(academicPct: 0, studentPct: 0, teacherPct: 100).score,
        closeTo(30, 0.01));
  });

  test('the score reports its own composition', () {
    final FitScore fit =
        composeFitScore(academicPct: 80, studentPct: 60, teacherPct: 70);
    expect(fit.academicContribution, closeTo(32, 0.01));
    expect(fit.studentContribution, closeTo(18, 0.01));
    expect(fit.teacherContribution, closeTo(21, 0.01));
    expect(fit.score, closeTo(71, 0.01));
  });

  test('verdict bands match the reference', () {
    expect(verdictFor(80), FitVerdict.greatFit);
    expect(verdictFor(75), FitVerdict.greatFit);
    expect(verdictFor(60), FitVerdict.acceptable);
    expect(verdictFor(55), FitVerdict.acceptable);
    expect(verdictFor(40), FitVerdict.mismatch);
    expect(verdictFor(35), FitVerdict.mismatch);
    expect(verdictFor(20), FitVerdict.strongMismatch);
  });

  test('the rule-based recommendation covers every band', () {
    for (final double score in <double>[0, 34, 35, 54, 55, 74, 75, 100]) {
      expect(ruleBasedRecommendation(score), isNotEmpty);
    }
  });

  test('a missing reflection reweights rather than scoring zero', () {
    // academic 0.4 and teacher 0.3 renormalised to sum 1 => 4/7 and 3/7.
    // 80*4/7 + 70*3/7 = 45.714 + 30 = 75.714.
    final FitScore fit =
        composeFitScore(academicPct: 80, studentPct: null, teacherPct: 70);
    expect(fit.score, closeTo(75.71, 0.1));
    expect(fit.studentContribution, 0);
    expect(fit.componentsUsed, <String>['academic', 'teacher']);
    // Not the same as scoring the reflection zero, which would be lower.
    expect(fit.score,
        greaterThan(composeFitScore(academicPct: 80, studentPct: 0, teacherPct: 70).score!));
  });

  test('all three components missing yields no score rather than zero', () {
    final FitScore fit = composeFitScore();
    expect(fit.score, isNull);
    expect(fit.verdict, isNull);
    expect(fit.componentsUsed, isEmpty);
  });
}
