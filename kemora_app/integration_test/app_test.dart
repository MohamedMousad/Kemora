import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kemora/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End full user journey', (WidgetTester tester) async {
    // Clear preferences to ensure a clean state (not logged in, onboarding not seen)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Start the app
    app.main();
    // Splash screen uses Future.delayed for 2.5 seconds, so we need to pump time
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 1. Handle Onboarding Screen (if first time launch)
    final skipButton = find.text('SKIP');
    if (skipButton.evaluate().isNotEmpty) {
      await tester.tap(skipButton);
      await tester.pumpAndSettle();
    }

    // Now we should be on the Login screen
    expect(find.text('KEMORA'), findsWidgets);
    expect(find.text('Welcome Back'), findsWidgets);

    // 2. Go to Register Screen
    final createAccountText = find.text('Create an account');
    expect(createAccountText, findsOneWidget);
    await tester.tap(createAccountText);
    await tester.pumpAndSettle();

    // 3. Register a new user
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'testuser_$timestamp@example.com';
    final testPassword = 'Password123!';

    await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'), 'E2E Test User');
    await tester.enterText(
        find.widgetWithText(TextField, 'Email Address'), testEmail);
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), testPassword);
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'), testPassword);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
    
    // Wait for the API call and navigation
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. Verify we are on the Home Screen (Explore Tab)
    // Looking for some known elements like the Kemora title or the BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Check if the greeting shows up
    expect(find.textContaining('Hello, E2E Test User'), findsWidgets);

    // Let places load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 5. Navigate to Social Tab
    final socialTab = find.text('Social');
    await tester.tap(socialTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Create a new post
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello from E2E integration test!');
      await tester.tap(find.text('POST'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify post appears in the feed
      expect(find.text('Hello from E2E integration test!'), findsWidgets);
    }

    // 6. Navigate to Trip Tab
    final tripTab = find.text('Trip');
    await tester.tap(tripTab);
    await tester.pumpAndSettle();

    // Fill in AI Trip form
    final destinationInput = find.widgetWithText(TextField, 'Where do you want to go?');
    if (destinationInput.evaluate().isNotEmpty) {
      await tester.enterText(destinationInput, 'Cairo');
      
      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate Magic Itinerary');
      if (generateBtn.evaluate().isNotEmpty) {
        await tester.tap(generateBtn);
        // Generation can take a while, up to 10 seconds.
        await tester.pumpAndSettle(const Duration(seconds: 15));
        
        // Verify itinerary loaded
        expect(find.textContaining('Day 1'), findsWidgets);
        
        // Click Save Plan
        final savePlanBtn = find.text('Save Plan');
        if (savePlanBtn.evaluate().isNotEmpty) {
            await tester.ensureVisible(savePlanBtn);
            await tester.tap(savePlanBtn);
            await tester.pumpAndSettle();
            
            // The Save Plan button opens a date picker, tap OK
            final okButton = find.text('OK');
            if (okButton.evaluate().isNotEmpty) {
                await tester.tap(okButton);
                await tester.pumpAndSettle(const Duration(seconds: 5));
            }
            
            // Verify success snackbar
            expect(find.textContaining('Plan saved successfully'), findsWidgets);
        } else {
            // Navigate back
            final backButton = find.byTooltip('Back');
            if (backButton.evaluate().isNotEmpty) {
                await tester.tap(backButton);
                await tester.pumpAndSettle();
            }
        }
      }
    }

    // 7. Navigate to Profile Tab
    final profileTab = find.text('Profile');
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    // Verify profile data
    expect(find.text('E2E Test User'), findsWidgets);
    expect(find.text(testEmail), findsWidgets);

    // 8. Logout
    final logoutBtn = find.text('Logout');
    if (logoutBtn.evaluate().isNotEmpty) {
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();
        
        // Verify we are back to login screen
        expect(find.text('Welcome Back'), findsWidgets);
    }
  });
}
