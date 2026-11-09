import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stark_vms/core/errors/api_exception.dart';
import 'package:stark_vms/data/auth/auth_service.dart';
import 'package:stark_vms/models/auth_session.dart';
import 'package:stark_vms/models/auth_user.dart';
import 'package:stark_vms/router/app_router.dart';
import 'package:stark_vms/screens/auth/register_screen.dart';

class FakeAuthServiceForRegister extends AuthService {
  bool registerCalled = false;
  bool shouldThrow409 = false;
  bool emailExistsResult = false;

  @override
  Future<bool> checkEmailExists(String email, {http.Client? client}) async {
    return emailExistsResult;
  }

  @override
  Future<AuthSession> register(
    String name,
    String email,
    String password, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    registerCalled = true;
    if (shouldThrow409) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_EMAIL',
        message: 'An account with this email address already exists.',
      );
    }
    final session = AuthSession(
      accessToken: 'registered-jwt',
      tokenType: 'Bearer',
      expiresIn: 900,
      expiresAt: DateTime.now().add(const Duration(seconds: 900)),
      user: AuthUser(email: email),
      sessionId: 1,
    );
    return session;
  }
}

void main() {
  late FakeAuthServiceForRegister fakeAuthService;

  setUp(() {
    fakeAuthService = FakeAuthServiceForRegister();
    AuthService.setInstanceForTesting(fakeAuthService);
  });

  Widget buildTestApp({Object? arguments}) {
    return MaterialApp(
      initialRoute: AppRouter.registerRoute,
      onGenerateRoute: (settings) {
        if (settings.name == AppRouter.registerRoute) {
          return MaterialPageRoute(
            settings: RouteSettings(name: AppRouter.registerRoute, arguments: arguments),
            builder: (_) => const RegisterScreen(),
          );
        }
        return AppRouter.generateRoute(settings);
      },
    );
  }

  testWidgets('Renders clean Register Screen without autofill or test password buttons', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Verify Brand Header and Title
    expect(find.text('STARK GROUP'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Enter your details below to register for the fleet portal.'), findsOneWidget);
    expect(find.textContaining('Security Advisory:'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Email Address *'), findsOneWidget);
    expect(find.text('Password *'), findsOneWidget);
    expect(find.text('Confirm Password *'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Return to Home'), findsOneWidget);

    // Verify unwanted helpers are NOT present
    expect(find.textContaining('Auto-Fill'), findsNothing);
    expect(find.textContaining('Quick-Fill'), findsNothing);
    expect(find.textContaining('Fill Test Password'), findsNothing);
  });

  testWidgets('Prefills email from route arguments when navigated from login', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(arguments: 'prefilled@starkgroup.test'));
    await tester.pumpAndSettle();

    expect(find.text('prefilled@starkgroup.test'), findsOneWidget);
  });

  testWidgets('Validates mismatched passwords', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Tony Stark'), 'Tony Stark');
    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. user@example.com'), 'tony@starkgroup.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter secure fleet password'), 'Password123!');
    await tester.enterText(find.widgetWithText(TextFormField, 'Re-enter password'), 'DifferentPassword123!');

    final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('Shows Account Already Exists banner on HTTP 409 conflict with Sign In button', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    fakeAuthService.shouldThrow409 = true;

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Tony Stark'), 'Tony Stark');
    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. user@example.com'), 'existing@starkgroup.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter secure fleet password'), 'Password123!');
    await tester.enterText(find.widgetWithText(TextFormField, 'Re-enter password'), 'Password123!');

    final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Account Already Exists'), findsOneWidget);
    expect(find.textContaining('is already registered'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });

  testWidgets('Shows Account Already Exists banner when checkEmailExists returns true', (tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    fakeAuthService.emailExistsResult = true;

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Tony Stark'), 'Tony Stark');
    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. user@example.com'), 'existing@starkgroup.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter secure fleet password'), 'Password123!');
    await tester.enterText(find.widgetWithText(TextFormField, 'Re-enter password'), 'Password123!');

    final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    expect(find.text('Account Already Exists'), findsOneWidget);
    expect(find.textContaining('is already registered'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });
}
