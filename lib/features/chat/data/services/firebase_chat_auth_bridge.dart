import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/chat_remote_datasource.dart';

/// Bridges the app's Sanctum session to Firebase Auth so the client can
/// access Firestore under security rules keyed on `request.auth.uid`.
class FirebaseChatAuthBridge {
  final FirebaseAuth _auth;
  final ChatRemoteDataSource _remote;

  FirebaseChatAuthBridge(this._auth, this._remote);

  Future<String> ensureSignedIn({
    required bool isTeacher,
    required String expectedUid,
  }) async {
    final current = _auth.currentUser;
    if (current != null && current.uid == expectedUid) {
      return current.uid;
    }
    if (current != null && current.uid != expectedUid) {
      await _auth.signOut();
    }
    final token = await _remote.getFirebaseToken(isTeacher: isTeacher);
    final credential = await _auth.signInWithCustomToken(token);
    return credential.user!.uid;
  }
}
