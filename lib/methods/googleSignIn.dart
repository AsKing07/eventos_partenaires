// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/pages/userInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String? name;
String? email;
String? imageUrl;
String? phoneNumber;

Future<String> signInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount?.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication?.accessToken,
    idToken: googleSignInAuthentication?.idToken,
  );
  final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
  final User? user = userCredential.user;
  assert(!user!.isAnonymous);
  assert(await user!.getIdToken() != null);
  final User? currentUser = await _auth.currentUser;
  assert(user!.uid == currentUser!.uid);
  assert(user!.email != null);
  assert(user!.displayName != null);

  final DocumentSnapshot x =
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

  if (x.exists) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', true);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  } else {
    name = user.displayName!;
    email = user.email!;
    if (user.phoneNumber != null) {
      phoneNumber = user.phoneNumber!;
    } else {
      phoneNumber = "Non défini";
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return UserInfoPage(phoneNumber!, email!, name!, true);
    }));
  }

  return 'signInWithGoogle succeeded: $user';
}

void signOut() async {
  await googleSignIn.signOut();
  await FirebaseAuth.instance.signOut();
  print("User Sign Out");
}
