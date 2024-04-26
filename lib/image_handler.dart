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

  FirebaseFirestore getFirestore() {
    return _firestore;
  }

  // Function to pick an image
  Future<XFile?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

 // Function to upload image to Firebase Storage and add reference to Firestore including initial average rating
Future<String> uploadImage(XFile image, String imageType) async {
  File file = File(image.path);
  String fileName = Path.basename(image.path);
  User? currentUser = _auth.currentUser;
  if (currentUser == null) {
    print("User not logged in");
    return '';
  }
  try {
    // Determine paths based on the type of image
    String storagePath;
    String firestoreCollection;
    if (imageType == 'profile') {
      storagePath = 'profilePictures/${currentUser.uid}/$fileName';
      firestoreCollection = 'userProfiles';
    } else {
      storagePath = 'uploads/${currentUser.uid}/$fileName';
      firestoreCollection = 'images';
    }

    Reference ref = _storage.ref().child(storagePath);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    if (snapshot.state == TaskState.success) {
      String downloadUrl = await ref.getDownloadURL();

      // Conditional logic based on image type
      if (imageType == 'profile') {
        // Overwrite or merge data into the user's profile document
        await _firestore.collection(firestoreCollection).doc(currentUser.uid).set({
          'imageUrl': downloadUrl,
          'uploadTime': FieldValue.serverTimestamp(),
          'imageName': fileName,
          'profilePictureUrl': downloadUrl,
        }, SetOptions(merge: true));
      } else {
        // Create a new document for each new feed image
        await _firestore.collection(firestoreCollection).add({
          'uploaderUid': currentUser.uid,
          'imageUrl': downloadUrl,
          'uploadTime': FieldValue.serverTimestamp(),
          'imageName': fileName,
          'averageRating': 0.0,  // Initial average rating set to 0.0
        });
      }

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



  // Function to calculate the average rating for an image
  Future<double> calculateAverageRating(String imageName) async {
    QuerySnapshot ratingsSnapshot = await _firestore.collection('userRatings')
      .where('imageName', isEqualTo: imageName)
      .get();

    double totalRating = 0;
int count = 0;

ratingsSnapshot.docs.forEach((doc) {
  var docData = doc.data() as Map<String, dynamic>;  // Explicit cast
  double? rating = docData['rating'] as double?;     // Accessing with cast
  if (rating != null) {
    totalRating += rating;
    count++;
  }
});


    return count > 0 ? totalRating / count : 0.0;
  }

  // Function to add or update a rating
  Future<void> addOrUpdateRating(String imageName, double rating) async {
  User? currentUser = _auth.currentUser;
  if (currentUser == null) {
    print("User not logged in");
    return;
  }

  var ratingsCollection = _firestore.collection('userRatings');
  QuerySnapshot existingRating = await ratingsCollection
    .where('imageName', isEqualTo: imageName)
    .where('userId', isEqualTo: currentUser.uid)
    .get();

  if (existingRating.docs.isEmpty) {
    // Add new rating
    await ratingsCollection.add({
      'imageName': imageName,
      'userId': currentUser.uid,
      'rating': rating,
    });
  } else {
    // Update existing rating
    await ratingsCollection.doc(existingRating.docs.first.id)
      .update({'rating': rating});
  }

  // Recalculate the average rating
  QuerySnapshot newRatings = await ratingsCollection
    .where('imageName', isEqualTo: imageName)
    .get();

  double totalRating = 0;
  newRatings.docs.forEach((doc) {
    totalRating += (doc.data() as Map<String, dynamic>)['rating'];
  });

  double averageRating = totalRating / newRatings.docs.length;

  // Update the image document with the new average rating
  await _firestore.collection('images')
    .where('imageName', isEqualTo: imageName)
    .get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.update({'averageRating': averageRating});
      });
  });
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
