import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:final_project/navigation_bar.dart' as custom_nav;
import 'image_handler.dart'; // Assuming the correct path
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 2;
  final ImageHandler _imageHandler = ImageHandler();
  final TextEditingController _imageNameController = TextEditingController();

  Stream<List<DocumentSnapshot>> getImagesStream() {
    return _imageHandler.getFirestore()
        .collection('images')
        .orderBy('averageRating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
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
      String imageName = _imageNameController.text;
      String downloadUrl = await _imageHandler.uploadImage(pickedFile, imageName);
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

              return FeedCard(imageData: data, imageHandler: _imageHandler);
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

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> imageData;
  final ImageHandler imageHandler;

  FeedCard({Key? key, required this.imageData, required this.imageHandler}) : super(key: key);

  @override
  _FeedCardState createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late double _currentRating = 1;  // Default initial rating

  @override
  void initState() {
    super.initState();
    _initializeRating();
  }

  void _initializeRating() async {
    double rating = await widget.imageHandler.calculateAverageRating(widget.imageData['imageName']);
    setState(() {
      _currentRating = rating;
    });
  }

  void _updateRating(double newRating) {
    setState(() {
      _currentRating = newRating;
    });
    widget.imageHandler.addOrUpdateRating(widget.imageData['imageName'], newRating);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          widget.imageHandler.displayImage(widget.imageData['imageUrl']),
          Slider(
            min: 0,
            max: 10,
            divisions: 10,
            value: _currentRating,
            label: _currentRating.round().toString(),
            onChanged: _updateRating,
          ),
        ],
      ),
    );
  }
}
