import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  void showToast(String text) {
    try {
      DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          builder: (context) {
            return ToastCard(title: Text(text));
          }).show(context);
    } catch (e) {
      print(e);
    }
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user with this email';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password';
        } else {
          message = 'Login failed. Try Again';
        }
        showToast(message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'ChitChat',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter email';
                          }
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            hintText: 'Enter email',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 82, 152, 210),
                            )),
                        controller: emailController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            hintText: 'Enter password',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color.fromARGB(255, 82, 152, 210),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                icon: Icon(isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off))),
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          login();
                        },
                        child: const Text('Login',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 82, 152, 210),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account?',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 82, 152, 210)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen()));
                            },
                          )
                        ],
                      ),
                    ]))));
  }
}
