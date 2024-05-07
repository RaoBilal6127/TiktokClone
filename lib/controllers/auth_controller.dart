import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user.dart' as model;
import 'package:tiktok_clone/views/screens/auth/home_screen.dart';
import 'package:tiktok_clone/views/screens/auth/login_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<File?> _pickedImage;
  late Rx<User?> _user;
  User get user => _user.value!;
  @override
  void onReady() {
    _user = Rx<User?>(firesbaseAuth.currentUser);
    _user.bindStream(firesbaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(LoginScreen());
    } else {
      Get.offAll(const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      Get.snackbar('profile Picture',
          'You have successfully selected your profile picture!');
    }
    _pickedImage = Rx<File?>(File(pickedImage!.path));
  }

  File? get profilePhoto => _pickedImage.value;
  Future<String> _uploadToStorage(File image) async {
    Reference ref = firesbaseStorage
        .ref()
        .child('profilePics')
        .child(firesbaseAuth.currentUser!.uid);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.trim().isNotEmpty &&
          email.trim().isNotEmpty &&
          password.trim().isNotEmpty &&
          image != null) {
        UserCredential cred = await firesbaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          email: email,
          username: username,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        print('register successfully');
      } else {
        Get.snackbar('Error creating Account', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error creating Account', e.toString());
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
        await firesbaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        print('Login success');
      } else {
        Get.snackbar('Error Logging in', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error Logging in', e.toString());
    }
  }
  void signOut()async{
    await firesbaseAuth.signOut();
  }
}
