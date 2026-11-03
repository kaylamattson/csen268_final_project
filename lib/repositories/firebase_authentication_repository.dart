import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_repository.dart';

class FirebaseAuthenticationRepository
    implements AuthenticationRepository {
  final FirebaseAuth _auth;

  FirebaseAuthenticationRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> newUser({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }
}