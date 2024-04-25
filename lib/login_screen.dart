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
          MaterialPageRoute(builder: (context) => SignupScreen(userCredential: userCredential)),
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
          title: Text("Registration"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _signupEmailController,
                  decoration: InputDecoration(hintText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _signupPasswordController,
                  decoration: InputDecoration(hintText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context). pop(),
            ),
            TextButton(
              child: Text("Sign Up"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await _signUp(_signupEmailController.text, _signupPasswordController.text);
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
        title: Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: _showSignUpDialog,
                child: Text("Not registered yet? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
