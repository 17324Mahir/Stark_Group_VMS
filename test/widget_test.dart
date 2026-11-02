import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/main.dart';

void main() {
  testWidgets('App renders login screen on launch', (WidgetTester tester) async {
    // Set a desktop-sized test screen viewport
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Verify login screen elements appear
    expect(find.text('STARK VMS'), findsAtLeast(1));
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
  });

  testWidgets('Admin can log in and view vehicle fleet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Tap login button
    final loginBtn = find.text('Sign In to Dashboard');
    expect(loginBtn, findsOneWidget);
    await tester.tap(loginBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify vehicle list screen is displayed
    expect(find.text('Fleet Vehicles'), findsAtLeast(1));
    expect(find.text('Register Vehicle'), findsAtLeast(1));
  });
}
