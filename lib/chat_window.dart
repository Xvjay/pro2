import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user info

class ChatWindow extends StatefulWidget {
  final String boardId;
  final String boardName;

  const ChatWindow({required this.boardId, required this.boardName});

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messageBoards')
                  .doc(widget.boardId)
                  .collection('messages')
                  .orderBy('datetime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");
                if (!snapshot.hasData) return CircularProgressIndicator();

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index];
                    return ListTile(
                      title: Text(msg['message']),
                      subtitle: Text('${msg['datetime'].toDate()} - ${msg['username']}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      var message = _messageController.text;
      User? user = _auth.currentUser;

      if (user != null) {
        var messagesRef = FirebaseFirestore.instance
            .collection('messageBoards')
            .doc(widget.boardId)
            .collection('messages');
        
        messagesRef.add({
          'message': message,
          'datetime': FieldValue.serverTimestamp(),
          'username': user.email ?? user.uid, // Using email or UID as username
        });

        _messageController.clear();
      }
    }
  }
}
