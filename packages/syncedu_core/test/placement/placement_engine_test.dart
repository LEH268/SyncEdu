import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

StudentProfile profile({required String id, String? dominant}) =>
    StudentProfile(id: id, dominant: dominant);

void main() {
  test('a student is matched to the class whose TARGET STYLE matches theirs', () {
    // Not the class NAME. The reference substring-matched the dominant letter
    // against the name, so "Year 1 Alpha" absorbed every auditory student.
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[profile(id: 's1', dominant: 'A')],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'Year 1 Alpha', targetStyle: 'V', size: 0),
        const ClassOption(id: 'c2', name: 'Year 1 Beta', targetStyle: 'A', size: 0),
      ],
    );
    expect(s.single.classId, 'c2');
  });

  test('class size breaks a tie between matching classes', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[profile(id: 's1', dominant: 'A')],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'A1', targetStyle: 'A', size: 5),
        const ClassOption(id: 'c2', name: 'A2', targetStyle: 'A', size: 2),
      ],
    );
    expect(s.single.classId, 'c2');
  });

  test('with no matching target style, the smallest class wins', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[profile(id: 's1', dominant: 'K')],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'V1', targetStyle: 'V', size: 9),
        const ClassOption(id: 'c2', name: 'R1', targetStyle: 'R', size: 3),
      ],
    );
    expect(s.single.classId, 'c2');
  });

  test('placements balance as they are assigned', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[
        for (int i = 0; i < 6; i++) profile(id: 's$i', dominant: 'A'),
      ],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'A1', targetStyle: 'A', size: 0),
        const ClassOption(id: 'c2', name: 'A2', targetStyle: 'A', size: 0),
      ],
    );
    final int c1 = s.where((x) => x.classId == 'c1').length;
    final int c2 = s.where((x) => x.classId == 'c2').length;
    expect(c1, 3);
    expect(c2, 3);
  });

  test('a student with no profile is left unassigned rather than guessed', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[profile(id: 's1')],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'A1', targetStyle: 'A', size: 0),
      ],
    );
    expect(s.single.classId, isNull);
    expect(s.single.rationale, isNotEmpty);
  });

  test('no classes at all yields unassigned suggestions, not an exception', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[profile(id: 's1', dominant: 'A')],
      classes: const <ClassOption>[],
    );
    expect(s.single.classId, isNull);
  });

  test('the same input yields the same output', () {
    List<PlacementDecision> run() => suggestPlacements(
          students: <StudentProfile>[
            profile(id: 's1', dominant: 'A'),
            profile(id: 's2', dominant: 'A'),
            profile(id: 's3', dominant: 'V'),
          ],
          classes: <ClassOption>[
            const ClassOption(id: 'c1', name: 'A1', targetStyle: 'A', size: 0),
            const ClassOption(id: 'c2', name: 'A2', targetStyle: 'A', size: 0),
            const ClassOption(id: 'c3', name: 'V1', targetStyle: 'V', size: 0),
          ],
        );
    final List<PlacementDecision> a = run();
    final List<PlacementDecision> b = run();
    expect(a.map((x) => x.classId).toList(), b.map((x) => x.classId).toList());
  });

  test('every suggestion carries the reason it was made', () {
    final List<PlacementDecision> s = suggestPlacements(
      students: <StudentProfile>[
        profile(id: 's1', dominant: 'A'),
        profile(id: 's2', dominant: 'K'),
        profile(id: 's3'),
      ],
      classes: <ClassOption>[
        const ClassOption(id: 'c1', name: 'A1', targetStyle: 'A', size: 0),
      ],
    );
    for (final PlacementDecision x in s) {
      expect(x.rationale, isNotEmpty);
    }
  });
}
