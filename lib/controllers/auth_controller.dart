import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user.dart' as models;
import 'package:tiktok_clone/views/screen/auth/login_screen.dart';
import 'package:tiktok_clone/views/screen/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  late Rx<File?> _pickedImage;

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, setInitialScreen);
  }

  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar(
        'Profile Picture',
        'You have successfully selected your profile picture!',
      );
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  void registerUser(
    String username,
    String email,
    String password,
    File? image,
  ) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential userCredential =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String urlImage = await _uploadToStorage(image);

        models.User user = models.User(
          email: email,
          name: username,
          uid: userCredential.user!.uid,
          profilePhoto: urlImage,
        );

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar('Error creating account', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error creating account', e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('OKE');
      } else {
        Get.snackbar('Error logging', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error logging', e.toString());
    }
  }

  Future<String> _uploadToStorage(File image) async {
    Reference reference = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
