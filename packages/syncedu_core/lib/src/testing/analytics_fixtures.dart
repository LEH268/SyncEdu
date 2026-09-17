/// Test fixture builder for analytics rows.
library;

import '../analytics/inputs.dart';

/// Chainable builder for generating deterministic analytics test data.
///
/// Generates consistent, fully deterministic row sets. The seed parameter is
/// retained for API stability and potential future use.
class FixtureBuilder {
  FixtureBuilder({required int seed});

  String? _classId;
  String? _className;
  final List<String> _studentIds = <String>[];
  final Map<String, String> _chapters = <String, String>{};
  final Map<String, List<String>> _chapterSkills = <String, List<String>>{};
  final List<({String studentId, String skill, int correct, int wrong, String mode})>
      _answers = <({String studentId, String skill, int correct, int wrong, String mode})>[];

  /// Set the class for this fixture.
  FixtureBuilder withClass({required String id, required String name}) {
    _classId = id;
    _className = name;
    return this;
  }

  /// Generate students for this fixture.
  FixtureBuilder withStudents({required int count, String? idPrefix}) {
    for (int i = 0; i < count; i++) {
      _studentIds.add(idPrefix == null ? 'student$i' : '$idPrefix-$i');
    }
    return this;
  }

  /// Add a chapter with skills to this fixture.
  FixtureBuilder withChapter({
    required String id,
    required String title,
    required List<String> skills,
  }) {
    _chapters[id] = title;
    _chapterSkills[id] = skills;
    return this;
  }

  /// Record answers for all current students on a skill.
  FixtureBuilder answering({
    required String skill,
    required int correct,
    required int wrong,
    String mode = 'revise',
  }) {
    for (final String studentId in _studentIds) {
      _answers.add((studentId: studentId, skill: skill, correct: correct, wrong: wrong, mode: mode));
    }
    return this;
  }

  /// Record answers for a specific student on a skill.
  FixtureBuilder withStudentAnswering({
    required String studentId,
    required String skill,
    required int correct,
    required int wrong,
    String mode = 'revise',
  }) {
    // Ensure this student exists in the student list
    if (!_studentIds.contains(studentId)) {
      _studentIds.add(studentId);
    }
    _answers.add((studentId: studentId, skill: skill, correct: correct, wrong: wrong, mode: mode));
    return this;
  }

  /// Generate the analytics rows.
  List<AnalyticRow> build() {
    final List<AnalyticRow> rows = <AnalyticRow>[];

    // Find the chapter for this fixture (assume first one if multiple)
    final String chapterId = _chapters.keys.isNotEmpty ? _chapters.keys.first : 'unknown';
    final String chapterTitle = _chapters[chapterId] ?? 'Unknown';

    int attemptCounter = 0;

    for (final answer in _answers) {
      final String studentId = answer.studentId;
      final String skill = answer.skill;
      final int correctCount = answer.correct;
      final int wrongCount = answer.wrong;
      final String mode = answer.mode;

      // Generate correct answers
      for (int i = 0; i < correctCount; i++) {
        rows.add(
          AnalyticRow(
            studentId: studentId,
            studentName: 'Student for $studentId',
            classId: _classId ?? 'unknown',
            className: _className ?? 'Unknown',
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            microSkillId: skill,
            microSkillLabel: 'Skill $skill',
            subjectName: 'Mathematics',
            isCorrect: true,
            submittedAt: DateTime.utc(2024, 1, 1).add(Duration(minutes: attemptCounter)),
            mode: mode,
            attemptId: 'attempt$attemptCounter',
          ),
        );
        attemptCounter++;
      }

      // Generate wrong answers
      for (int i = 0; i < wrongCount; i++) {
        rows.add(
          AnalyticRow(
            studentId: studentId,
            studentName: 'Student for $studentId',
            classId: _classId ?? 'unknown',
            className: _className ?? 'Unknown',
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            microSkillId: skill,
            microSkillLabel: 'Skill $skill',
            subjectName: 'Mathematics',
            isCorrect: false,
            submittedAt: DateTime.utc(2024, 1, 1).add(Duration(minutes: attemptCounter)),
            mode: mode,
            attemptId: 'attempt$attemptCounter',
          ),
        );
        attemptCounter++;
      }
    }

    return rows;
  }
}
