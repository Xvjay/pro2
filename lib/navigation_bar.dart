import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const NavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        // Add new button for the Feed screen
        BottomNavigationBarItem(
          icon: Icon(Icons.image),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: widget.currentIndex,
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.blue[800],
      onTap: widget.onItemTapped,
    );
  }
}
