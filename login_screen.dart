import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  final auth = AuthService();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
  try {
    print("Login button pressed");

    setState(() {
      isLoading = true;
    });

    await auth.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    print("Login successful");

  } on FirebaseAuthException catch (e) {
    print(e.code);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? e.code)),
    );
  }

  setState(() {
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text(
              "Welcome Back",

              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(
                labelText: "Password",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : login,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },

              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
