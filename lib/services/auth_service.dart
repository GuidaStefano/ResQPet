import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Future<UserCredential> signUp(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  Future<void> updatePassword(String password) async {
    return currentUser?.updatePassword(password);
  }

  Future<void> updateEmail(String email) async {
    return currentUser?.verifyBeforeUpdateEmail(email);
  }

  Stream<User?> getAuthChanges() {
    return _auth.authStateChanges();
  }

  User? get currentUser =>  _auth.currentUser;
}