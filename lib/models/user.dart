import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String username;
  String email;
  String profilePhoto;
  String uid;
  User({
    required this.username,
    required this.email,
    required this.profilePhoto,
    required this.uid,
  });
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'profilePhoto': profilePhoto,
      'uid': uid
    };
  }

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String,dynamic>;
    return User(
        username: snapshot['username'],
        email: snapshot['email'],
        profilePhoto: snapshot['profilePhoto'],
        uid: snapshot['uid']);
  }
}
