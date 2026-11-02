import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stark_vms/data/mock_data.dart';
import 'package:stark_vms/data/vehicle_repository.dart';
import 'package:stark_vms/main.dart';

void main() {
  setUp(() {
    VehicleRepository.setInstanceForTesting(
      VehicleRepository.fake(initialVehicles: initialMockVehicles),
    );
  });

  testWidgets('1. Login screen renders with Stark Group branding and demo credentials',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    expect(find.text('STARK GROUP'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('demo@starkgroup.test'), findsAtLeast(1));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Autofill'), findsOneWidget);
  });

  testWidgets('2. Invalid login shows validation error or inline credentials alert',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // 1. Submit empty form
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email address.'), findsOneWidget);

    // 2. Submit wrong credentials
    await tester.enterText(
      find.widgetWithText(TextFormField, '').first,
      'wrong@starkgroup.test',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'WrongPass!123',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.text('Invalid credentials. Please use the demo credentials provided below.'),
      findsOneWidget,
    );
  });

  testWidgets('3. Autofill demo credentials and sign in navigates to Vehicles',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Click Autofill
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();

    // Tap Sign in
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify Vehicles screen loaded
    expect(find.text('Fleet Registry'), findsOneWidget);
    expect(find.text('Register vehicle'), findsOneWidget);
  });

  testWidgets('4. Search and filters work correctly on mock fleet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Enter search query
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Sprinter');
    await tester.pumpAndSettle();

    // Should find Mercedes-Benz Sprinter
    expect(find.text('STK-1001'), findsOneWidget);
    expect(find.text('Showing 1–1 of 1 vehicles'), findsOneWidget);

    // Clear filters
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Showing 1–10 of 18 vehicles'), findsOneWidget);
  });

  testWidgets('5. Sorting and pagination work on Vehicle List',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Check pagination summary
    expect(find.text('Showing 1–10 of 18 vehicles'), findsOneWidget);
    expect(find.text('Page 1 of 2'), findsOneWidget);

    // Navigate to page 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 11–18 of 18 vehicles'), findsOneWidget);
    expect(find.text('Page 2 of 2'), findsOneWidget);

    // Navigate back to page 1
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 2'), findsOneWidget);
  });

  testWidgets('6. Register a new vehicle and reject duplicate numbers',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Click Register vehicle
    await tester.tap(find.text('Register vehicle'));
    await tester.pumpAndSettle();

    expect(find.text('1. Vehicle Identity'), findsOneWidget);

    // Test duplicate detection with existing vehicle STK-1001
    final vehicleNumField = find.byType(TextFormField).at(0);
    await tester.enterText(vehicleNumField, 'stk-1001'); // Case-insensitive test
    await tester.enterText(find.byType(TextFormField).at(1), 'TestBrand');
    await tester.enterText(find.byType(TextFormField).at(2), 'TestModel');

    // Click Register vehicle button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register vehicle'));
    await tester.pumpAndSettle();

    // Expect duplicate error
    expect(find.textContaining('already registered'), findsOneWidget);

    // Now enter a unique number that sorts to page 1
    await tester.enterText(vehicleNumField, 'STK-0001');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register vehicle'));
    await tester.pumpAndSettle();

    // Should return to Vehicles screen with success SnackBar
    expect(find.text('Fleet Registry'), findsOneWidget);
    expect(find.text('Vehicle STK-0001 successfully registered.'), findsOneWidget);
    expect(find.text('STK-0001'), findsOneWidget);
  });

  testWidgets('7. Delete confirmation dialog cancels or confirms deletion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Find delete icon for first row
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsWidgets);

    // Tap first delete button
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Confirmation dialog should appear (title and button)
    expect(find.text('Delete Vehicle'), findsNWidgets(2));
    expect(find.text('Keep Vehicle'), findsOneWidget);

    // Cancel deletion
    await tester.tap(find.text('Keep Vehicle'));
    await tester.pumpAndSettle();

    // Dialog closed, vehicles still present
    expect(find.text('Delete Vehicle'), findsNothing);
  });

  testWidgets('8. Responsive layout works across Desktop, Tablet, and Mobile viewports',
      (WidgetTester tester) async {
    // 1440px desktop
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);

    // 1024px tablet
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);

    // 768px small tablet
    tester.view.physicalSize = const Size(768, 1024);
    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);

    // 390px mobile
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsWidgets);

    tester.view.resetPhysicalSize();
  });

  testWidgets('9. Edit vehicle updates existing record without creating duplicate',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Tap first edit button
    final editButtons = find.byIcon(Icons.edit_outlined);
    expect(editButtons, findsWidgets);
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Vehicle'), findsAtLeast(1));

    // Update the model field
    final modelField = find.byType(TextFormField).at(2);
    await tester.enterText(modelField, 'Sprinter Extended');

    // Save changes
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save changes'));
    await tester.pumpAndSettle();

    // Verify update reflected on Vehicles screen
    expect(find.text('Vehicle STK-1001 successfully updated.'), findsOneWidget);
    expect(find.text('Sprinter Extended'), findsOneWidget);
  });

  testWidgets('10. Canceling an edit with unsaved changes prompts discard confirmation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Tap first edit button
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    // Modify a field to make form dirty
    final brandField = find.byType(TextFormField).at(1);
    await tester.enterText(brandField, 'ModifiedBrand');

    // Tap Cancel button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Should prompt confirmation dialog
    expect(find.text('Discard Unsaved Changes?'), findsOneWidget);

    // Cancel the discard
    await tester.tap(find.text('Continue Editing'));
    await tester.pumpAndSettle();

    // Still on Edit screen
    expect(find.text('Edit Vehicle'), findsAtLeast(1));
  });

  testWidgets('11. Sign out returns to Login screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const StarkVmsApp());
    await tester.pumpAndSettle();

    // Sign in
    await tester.tap(find.text('Autofill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Tap sign out button in sidebar
    final signOutBtn = find.byTooltip('Sign out');
    expect(signOutBtn, findsOneWidget);
    await tester.tap(signOutBtn);
    await tester.pumpAndSettle();

    // Should be back on Login screen
    expect(find.text('Sign in to your account'), findsOneWidget);
  });
}
