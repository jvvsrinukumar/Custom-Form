import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/main.dart';
import 'package:custom_form/ui/address_entry/address_entry_page.dart';
import 'package:custom_form/ui/login/login_page.dart';
import 'package:custom_form/ui/navigation_page.dart';
import 'package:custom_form/ui/phone_number/phone_number_page.dart';
import 'package:custom_form/ui/register/register_page.dart';
import 'package:custom_form/ui/login_phone/login_phone_page.dart'; // Add this
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NavigationPage renders correctly and navigates', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp()); // Using MyApp to ensure MaterialApp context

    // Verify that NavigationPage is the home page.
    expect(find.byType(NavigationPage), findsOneWidget);
    expect(find.text('Main Navigation'), findsOneWidget);

    // Verify that all buttons are present.
    expect(find.widgetWithText(ElevatedButton, 'Login Page'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Address Page (No Data)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Address Page (With Data)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Register Page'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Phone Number Page'), findsOneWidget);

    // Test navigation to LoginPage
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login Page'));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login'), findsOneWidget); // Assuming LoginPage has 'Login' in its AppBar
    await tester.pageBack(); // Go back to NavigationPage
    await tester.pumpAndSettle();

    // Test navigation to AddressEntryPage (No Data)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Address Page (No Data)'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEntryPage), findsOneWidget);
    // Check for a title that indicates no data was passed (e.g., 'Add Address')
    // This requires AddressEntryPage to set its title based on whether initialData is present.
    // Assuming 'Add Address' is the title when no data is passed.
    expect(find.text('Add Address'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test navigation to AddressEntryPage (With Data)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Address Page (With Data)'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressEntryPage), findsOneWidget);
    // Check for a title that indicates data was passed (e.g., 'Edit Address')
    // This requires AddressEntryPage to set its title based on whether initialData is present.
    // Assuming 'Edit Address' is the title when data is passed.
    expect(find.text('Edit Address'), findsOneWidget);
    // You could also verify that some data from the sampleAddress is displayed if the page does so.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test navigation to RegisterPage
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register Page'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.text('Register'), findsOneWidget); // Assuming RegisterPage has 'Register' in its AppBar
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test navigation to PhoneNumberPage
    await tester.tap(find.widgetWithText(ElevatedButton, 'Phone Number Page'));
    await tester.pumpAndSettle();
    expect(find.byType(PhoneNumberPage), findsOneWidget);
    // Add specific checks for PhoneNumberPage if needed, e.g., AppBar title
    // For now, just checking the page type is sufficient for navigation.
    // expect(find.text('Enter Phone Number'), findsOneWidget); // Example check
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
