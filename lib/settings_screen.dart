import 'package:final_project/theme/themepro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'navigation_bar.dart' as custom_nav;
import 'profile_screen.dart';
import 'message_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;

  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      bottomNavigationBar: custom_nav.NavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Email: ${_auth.currentUser?.email ?? "Not available"}'),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(15)),
              height: 50,
              width: 330,
              child: Row(
                children: [
                  Text("Dark/Light Mode"),
                  Spacer(
                    flex: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlutterSwitch(
                        height: 30,
                        width: 60,
                        value: status,
                        onToggle: (val) {
                          Provider.of<Themeprovider>(context, listen: false)
                              .toggle();
                          setState(() {
                            status = val;
                          });
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != 3) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/messages');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/feed');
          break;
      }
    }
  }

  void _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      print("Logout Error: $e");
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text('Failed to log out. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}
