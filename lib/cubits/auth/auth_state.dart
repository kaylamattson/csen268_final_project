import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthWaiting extends AuthState {}

class AuthError extends AuthState {
  final String errorText;

  AuthError(this.errorText);
}

class AuthLoggedIn extends AuthState {
  final User user;

  AuthLoggedIn(this.user);
}
