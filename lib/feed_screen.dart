import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project/navigation_bar.dart' as custom_nav;
import 'image_handler.dart'; // Make sure this import is correct
import 'package:image_picker/image_picker.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 2;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageHandler _imageHandler = ImageHandler(); // Instance of ImageHandler
  final TextEditingController _imageNameController = TextEditingController();

  Stream<List<DocumentSnapshot>> getImagesStream() {
    return _firestore
        .collection('images')
        .orderBy('rating',
            descending: true) // Sort by rating in descending order
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void updateImageRating(String docId, double rating) {
    _firestore.collection('images').doc(docId).update({'rating': rating});
  }

  void onItemTapped(int index) {
    if (index != 2) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/messages');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _imageNameController,
                decoration: InputDecoration(labelText: 'Image Name'),
              ),
              ElevatedButton(
                onPressed: () {
                  _uploadImage();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Pick and Upload'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadImage() async {
    final XFile? pickedFile = await _imageHandler.pickImage();
    if (pickedFile != null) {
      String downloadUrl = await _imageHandler.uploadImage(pickedFile);
      if (downloadUrl.isNotEmpty) {
        // Optionally show a message or update UI upon successful upload
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Feed'),
        actions: [
          // Add sorting and filtering functionality if needed
        ],
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: getImagesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No images found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data![index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              double rating = data['rating'] ?? 0.0;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.network(
                      data['imageUrl'],
                      fit: BoxFit.cover,
                      // Placeholder and error widgets can be added for a better UX
                    ),
                    Slider(
                      min: 1,
                      max: 10,
                      divisions: 9,
                      value: rating,
                      label: rating.round().toString(),
                      onChanged: (newRating) {
                        setState(() {
                          // Update the local rating for immediate UI response
                          data['rating'] = newRating;
                        });
                        // Update the rating in Firestore
                        updateImageRating(doc.id, newRating);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: custom_nav.NavigationBar(
        currentIndex: _selectedIndex,
        onItemTapped: onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        tooltip: 'Upload Image',
        child: Icon(Icons.add_a_photo, color: Colors.black),
        backgroundColor: Colors.grey[400],
        elevation: 6,
      ),
    );
  }
}
