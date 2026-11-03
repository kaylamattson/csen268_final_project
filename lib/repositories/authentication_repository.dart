import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<UserCredential> newUser({
    required String email,
    required String password,
  });

  Future<void> signOut();
}