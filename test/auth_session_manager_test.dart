import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noor/core/auth/auth_session_manager.dart';
import 'package:noor/core/constants/app_constants.dart';
import 'package:noor/core/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LocalStorage> createStorage({
    Map<String, String> secureValues = const {},
    Map<String, Object> preferenceValues = const {},
  }) async {
    FlutterSecureStorage.setMockInitialValues(Map.of(secureValues));
    SharedPreferences.setMockInitialValues(Map.of(preferenceValues));
    final preferences = await SharedPreferences.getInstance();
    return LocalStorage(const FlutterSecureStorage(), preferences);
  }

  group('fresh installation', () {
    test('removes a secure token left by an uninstalled app', () async {
      final storage = await createStorage(
        secureValues: {AppConstants.tokenKey: 'old-token'},
      );

      await storage.initializeForLaunch();

      expect(await storage.getToken(), isNull);
      expect(
        (await SharedPreferences.getInstance())
            .getBool(AppConstants.installationMarkerKey),
        isTrue,
      );
    });

    test('keeps an existing user session during the first app update',
        () async {
      final storage = await createStorage(
        secureValues: {AppConstants.tokenKey: 'active-token'},
        preferenceValues: {
          AppConstants.userTypeKey: AppConstants.userTypeStudent,
        },
      );

      await storage.initializeForLaunch();

      expect(await storage.getToken(), 'active-token');
    });
  });

  group('expired session', () {
    test('clears a teacher session and emits the teacher login route',
        () async {
      final storage = await createStorage();
      await storage.saveToken('expired-token');
      await storage.saveUserType(AppConstants.userTypeTeacher);
      await storage.saveUserData({'id': 1});
      final manager = AuthSessionManager(storage);
      final loginRoute = manager.sessionExpired.first;

      await manager.handleUnauthorized('expired-token');

      expect(await loginRoute, '/teacher-login');
      expect(await storage.getToken(), isNull);
      expect(storage.getUserType(), isNull);
      expect(storage.getUserData(), isNull);
      manager.dispose();
    });

    test('ignores a late 401 response for an older token', () async {
      final storage = await createStorage();
      await storage.saveToken('new-token');
      await storage.saveUserType(AppConstants.userTypeStudent);
      final manager = AuthSessionManager(storage);
      var navigationCount = 0;
      final subscription = manager.sessionExpired.listen((_) {
        navigationCount++;
      });

      await manager.handleUnauthorized('old-token');

      expect(await storage.getToken(), 'new-token');
      expect(navigationCount, 0);
      await subscription.cancel();
      manager.dispose();
    });
  });
}
