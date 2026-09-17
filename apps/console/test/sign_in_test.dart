import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

Future<FakeAuthGateway> pumpSignIn(WidgetTester tester) async {
  final gateway = FakeAuthGateway();
  addTearDown(gateway.dispose);
  await tester.pumpWidget(
    MaterialApp(home: SignInScreen(gateway: gateway)),
  );
  return gateway;
}

Future<void> submit(
  WidgetTester tester,
  String email,
  String password,
) async {
  await tester.enterText(find.byKey(const Key('signin-email')), email);
  await tester.enterText(find.byKey(const Key('signin-password')), password);
  await tester.tap(find.byKey(const Key('signin-submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('submitting passes the trimmed email and raw password',
      (tester) async {
    final gateway = await pumpSignIn(tester);
    gateway.accepts['cikgu@test.syncedu.invalid:pw'] = const SessionClaims(
      userId: 'u',
      schoolId: 's',
      role: UserRole.teacher,
    );

    await submit(tester, '  cikgu@test.syncedu.invalid  ', 'pw');

    expect(gateway.calls, [('cikgu@test.syncedu.invalid', 'pw')]);
    expect(find.byKey(const Key('signin-error')), findsNothing);
  });

  testWidgets('a refused sign-in shows the failure message', (tester) async {
    await pumpSignIn(tester);

    await submit(tester, 'wrong@test.syncedu.invalid', 'nope');

    expect(find.byKey(const Key('signin-error')), findsOneWidget);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('the error clears when a second attempt is made',
      (tester) async {
    final gateway = await pumpSignIn(tester);
    gateway.accepts['right@test.syncedu.invalid:pw'] = const SessionClaims(
      userId: 'u',
      schoolId: 's',
      role: UserRole.admin,
    );

    await submit(tester, 'wrong@test.syncedu.invalid', 'nope');
    expect(find.byKey(const Key('signin-error')), findsOneWidget);

    await submit(tester, 'right@test.syncedu.invalid', 'pw');
    expect(find.byKey(const Key('signin-error')), findsNothing);
  });
}
