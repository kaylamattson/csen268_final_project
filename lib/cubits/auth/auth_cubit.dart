import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repositories/authentication_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthenticationRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> loginUser(String email, String password) async {
    emit(AuthWaiting());

    try {
      final result = await _repository.signIn(
        email: email,
        password: password,
      );

      emit(AuthLoggedIn(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed.'));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> registerUser(String email, String password) async {
    emit(AuthWaiting());

    try {
      final result = await _repository.newUser(
        email: email,
        password: password,
      );

      emit(AuthLoggedIn(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration failed.'));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> logoutUser() async {
    await _repository.signOut();
    emit(AuthInitial());
  }
}
