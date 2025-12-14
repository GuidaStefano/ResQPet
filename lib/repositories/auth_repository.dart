import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserCredential> signIn(String email, String password) async {
    return _authService.signIn(email, password);
  }

  Future<void> logout() async {
    return _authService.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    return _authService.updatePassword(newPassword);
  }

  Future<void> updateEmail(String newEmail) async {
    return _authService.updateEmail(newEmail);
  }

  User? getCurrentUser() {
    return _authService.currentUser;
  }
}
