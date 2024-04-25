import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation_bar.dart' as custom_nav;
import 'chat_window.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int _selectedIndex = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Message Boards")),
      bottomNavigationBar: custom_nav.NavigationBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: StreamBuilder<List<MessageBoard>>(
        stream: getMessageBoardsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final messageBoards = snapshot.data!;
          return ListView.builder(
            itemCount: messageBoards.length,
            itemBuilder: (context, index) {
              final board = messageBoards[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.message), // Placeholder for images
                  title: Text(board.title),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatWindow(
                              boardId: board.id, boardName: board.title),
                        ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBoardDialog(context),
        child: Icon(Icons.add,
            color: Colors.black), // Icon color set to black for contrast
        backgroundColor:
            Colors.grey[400], // Same cool grey color as the ElevatedButton
        elevation:
            6, // A bit higher elevation for a pronounced shadow, enhancing visibility
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != 1) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/feed');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }
  }

  Stream<List<MessageBoard>> getMessageBoardsStream() {
    return FirebaseFirestore.instance
        .collection('messageBoards')
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageBoard.fromFirestore(doc))
            .toList());
  }

  void _showAddBoardDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Message Board'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter board name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addMessageBoard(_controller.text);
              },
              child: Text('Create Board'),
            ),
          ],
        );
      },
    );
  }

  void _addMessageBoard(String boardName) {
    User? user = _auth.currentUser;

    if (user != null) {
      FirebaseFirestore.instance.collection('messageBoards').add({
        'title': boardName,
        'createdAt': FieldValue.serverTimestamp(),
        'creatorId': user.uid,
      });
    } else {
      print("No user logged in");
    }
  }
}

class MessageBoard {
  final String id;
  final String title;
  final String imageUrl;

  MessageBoard(
      {required this.id,
      required this.title,
      this.imageUrl = 'default_image.png'});

  factory MessageBoard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MessageBoard(
      id: doc.id,
      title: data['title'],
      imageUrl: data['imageUrl'] ?? 'default_image.png',
    );
  }
}
