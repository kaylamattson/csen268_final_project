import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../repositories/firebase_authentication_repository.dart';
import '../theme/app_colors.dart';
import 'tabs_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(FirebaseAuthenticationRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegistering = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TabsPage()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.light_mode_outlined,
                      size: 75,
                      color: C.ink,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Sensle',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: C.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isRegistering ? 'Create your account' : 'Welcome back!',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state is AuthError)
                      Text(
                        state.errorText,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    if (state is AuthWaiting)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: C.teal,
                            foregroundColor: C.ink,
                          ),
                          onPressed: () {
                            final cubit = context.read<AuthCubit>();

                            if (isRegistering) {
                              cubit.registerUser(
                                emailController.text,
                                passwordController.text,
                              );
                            } else {
                              cubit.loginUser(
                                emailController.text,
                                passwordController.text,
                              );
                            }
                          },
                          child: Text(
                            isRegistering ? 'Sign Up' : 'Log In',
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isRegistering = !isRegistering;
                        });
                      },
                      child: Text(
                        isRegistering
                            ? 'Already have an account? Log In'
                            : 'New to Sensle? Sign Up',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
