import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final UserCredential userCredential; // Accept UserCredential from the LoginScreen

  SignupScreen({Key? key, required this.userCredential}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _firstName;
  String? _lastName;
  String _userRole = 'user';  // Default role is 'user'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Registration'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'User Name'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your user name';
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      onSaved: (value) => _firstName = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      onSaved: (value) => _lastName = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: _userRole,
                      items: <String>['admin', 'user']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _userRole = newValue!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'User Role'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          _registerUser();
                        }
                      },
                      child: Text('Complete Registration'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _registerUser() async {
  setState(() {
    _isLoading = true;
  });

  final user = widget.userCredential.user; // Use the UserCredential passed from the LoginScreen
  if (user == null) {
    setState(() {
      _isLoading = false;
    });
    return;
  }

  final registrationDatetime = DateTime.now();

  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'username': _username,
    'firstName': _firstName,
    'lastName': _lastName,
    'userRole': _userRole,
    'uid': user.uid,
    'registrationDatetime': registrationDatetime,
  });

  setState(() {
    _isLoading = false;
  });

  // Navigate back to LoginScreen (or any other screen as per your flow)
  // Assuming LoginScreen needs to be pushed to stack for user to log in again
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
}

}
