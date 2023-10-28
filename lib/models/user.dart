import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String email;
  String phone;

  User(
      {required this.email,
      required this.name,
      required this.phone,
      required this.uid});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        email: doc['email'],
        uid: doc['uid'],
        phone: doc['phoneNumber'],
        name: doc['name']);
  }
}
