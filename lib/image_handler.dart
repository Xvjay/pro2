import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to pick an image
  Future<XFile?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  // Function to upload image to Firebase Storage and add reference to Firestore
  Future<String> uploadImage(XFile image) async {
    File file = File(image.path);
    String fileName = Path.basename(image.path);
    User? currentUser = _auth.currentUser; // Get the current logged in user
    if (currentUser == null) {
      print("User not logged in");
      return '';
    }
    try {
      // Uploading the selected image with a unique path
      Reference ref = _storage.ref().child('uploads/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      UploadTask uploadTask = ref.putFile(file);

      // Waiting for the upload to complete
      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        // Getting the download URL
        String downloadUrl = await ref.getDownloadURL();

        // Create a document in Firestore with the image URL, user details, and additional fields
        DocumentReference docRef = await _firestore.collection('images').add({
          'imageUrl': downloadUrl,
          'rating': 5.0, // Default rating
          'uploader': currentUser.uid, // User who uploaded the image
          'uploadTime': FieldValue.serverTimestamp(), // Time when the image was uploaded
          'imageName': fileName, // Initial image name
        });

        // Optionally, if you want to update the image name later, you can retrieve docRef and update it.
        // docRef.update({'imageName': 'newImageName.jpg'});

        return downloadUrl;
      } else {
        print('Error from image repo ${snapshot.state}');
        return '';
      }
    } on FirebaseException catch (e) {
      print(e);
      return '';
    }
  }

  // Function to show an uploaded image from Firebase Storage
  Widget displayImage(String imageUrl) {
    // In case of an empty URL, return a placeholder
    if (imageUrl.isEmpty) {
      return Icon(Icons.image); // or any other placeholder widget
    }

    // Otherwise, return the image from the internet
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
