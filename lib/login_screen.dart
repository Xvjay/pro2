import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        print("Login Successful");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MessageScreen()),
        );
      }
    } catch (e) {
      print("Login Error: $e");
    }
  }

  Future<void> _signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user != null) {
        print("Sign Up Successful");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SignupScreen(userCredential: userCredential)),
        );
      }
    } catch (e) {
      print("Sign Up Error: $e");
    }
  }

  void _showSignUpDialog() {
    final _signupEmailController = TextEditingController();
    final _signupPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.grey[800], // Light grey background for the dialog
          title: Text(
            "Registration",
            style: TextStyle(
              color: Colors.white, // Dark grey text for contrast
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _signupEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    fillColor: Colors.grey[700],
                    filled: true, // Background color for TextField
                  ),
                ),
                SizedBox(height: 10), // Adds space between fields
                TextField(
                  controller: _signupPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    fillColor: Colors.grey[700],
                    filled: true, // Background color for TextField
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style:
                    TextStyle(color: Colors.white), // Dark grey text for button
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "Sign Up",
                style:
                    TextStyle(color: Colors.white), // Dark grey text for button
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await _signUp(_signupEmailController.text,
                    _signupPasswordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("ARTGRAM"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    border:
                        OutlineInputBorder(), // Use OutlineInputBorder for consistent styling
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText:
                      true, // Ensures the password is hidden during entry
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                    labelText: "Password",
                    border:
                        OutlineInputBorder(), // Provides a consistent outlined appearance
                  ),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.grey.shade600),
                    padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 18)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _showSignUpDialog,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.blue),
                  padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                ),
                child: Text("Not registered yet? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
