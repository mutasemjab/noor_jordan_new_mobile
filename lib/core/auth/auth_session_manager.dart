import 'dart:async';

import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

/// Owns the one-time transition from an authenticated session to its login
/// page when the backend rejects the current token.
class AuthSessionManager {
  final LocalStorage _storage;
  final StreamController<String> _sessionExpiredController =
      StreamController<String>.broadcast();

  Future<void>? _expirationInProgress;

  AuthSessionManager(this._storage);

  Stream<String> get sessionExpired => _sessionExpiredController.stream;

  Future<void> handleUnauthorized(String rejectedToken) {
    final activeExpiration = _expirationInProgress;
    if (activeExpiration != null) return activeExpiration;

    final expiration = _expireIfCurrent(rejectedToken);
    _expirationInProgress = expiration;
    return expiration.whenComplete(() {
      if (identical(_expirationInProgress, expiration)) {
        _expirationInProgress = null;
      }
    });
  }

  Future<void> _expireIfCurrent(String rejectedToken) async {
    final currentToken = await _storage.getToken();

    // A response from an older request must never log out a newly signed-in
    // session. It also prevents several simultaneous 401 responses from
    // causing repeated navigation.
    if (currentToken == null || currentToken != rejectedToken) return;

    final userType = _storage.getUserType();
    await _storage.clearUserSession();

    final loginRoute = userType == AppConstants.userTypeTeacher
        ? '/teacher-login'
        : '/student-login';
    _sessionExpiredController.add(loginRoute);
  }

  void dispose() {
    _sessionExpiredController.close();
  }
}
