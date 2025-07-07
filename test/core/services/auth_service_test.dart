import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_pro_test/core/services/auth_service.dart';

// Mock Firebase options for testing
class MockFirebaseOptions extends FirebaseOptions {
  const MockFirebaseOptions()
      : super(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        );
}

void main() {
  group('AuthService', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      TestWidgetsFlutterBinding.ensureInitialized();
      try {
        await Firebase.initializeApp(
          options: const MockFirebaseOptions(),
        );
      } catch (e) {
        // Firebase might already be initialized
      }
    });

    test('should be a singleton', () {
      final authService1 = AuthService();
      final authService2 = AuthService();

      expect(authService1, equals(authService2));
    });

    test('should be a singleton', () {
      final authService1 = AuthService();
      final authService2 = AuthService();
      
      expect(authService1, equals(authService2));
    });

    test('should initially have no current user', () {
      final authService = AuthService();
      expect(authService.currentUser, isNull);
      expect(authService.isSignedIn, isFalse);
    });

    test('should provide auth state stream', () {
      final authService = AuthService();
      expect(authService.authStateChanges, isNotNull);
    });
  });
}
