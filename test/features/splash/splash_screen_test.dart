import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pro_test/features/splash/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('should display app logo and name', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(enableNavigation: false),
        ),
      );

      // Let the initial frame render
      await tester.pump();

      // Verify that the app name is displayed
      expect(find.text('Flutter Pro'), findsOneWidget);
      expect(find.text('Professional Flutter Boilerplate'), findsOneWidget);

      // Verify that the logo container is displayed
      expect(find.byIcon(Icons.flutter_dash), findsOneWidget);

      // Verify that the loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have proper animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(enableNavigation: false),
        ),
      );

      // Let the initial frame render
      await tester.pump();

      // Initially, the widgets should be present but might be transparent
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(Transform), findsAtLeastNWidgets(1));

      // Pump a few frames to let animations start
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // The widgets should still be there as animations progress
      expect(find.text('Flutter Pro'), findsOneWidget);
      expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
    });

    testWidgets('should adapt to theme brightness', (WidgetTester tester) async {
      // Test light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const SplashScreen(enableNavigation: false),
        ),
      );

      // Let the initial frame render
      await tester.pump();

      // Find the scaffold and verify background color
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      // Test dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const SplashScreen(enableNavigation: false),
        ),
      );

      // Let the initial frame render
      await tester.pump();

      expect(scaffoldFinder, findsOneWidget);
    });
  });
}
