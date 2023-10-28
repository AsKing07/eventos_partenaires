// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/Methods/getUserId.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/clipper.dart';
import '../config/size.dart';
import 'userInfo.dart';

class OTP extends StatefulWidget {
  OTP(this.phone);
  final String phone;
  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  String actualCode = '', status = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    phoneSignin();
  }

  void onAuthenticationSuccessful(UserCredential result) async {
    String uid = await getCurrentUid();
    final DocumentSnapshot x =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (x.exists) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('login', true);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          ModalRoute.withName('login'));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserInfoPage(widget.phone, '', '', false)));
    }
  }

  void _signInWithPhoneNumber(String smsCode) async {
    AuthCredential auth = PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);
    _auth.signInWithCredential(auth).catchError((error) {
      setState(() {
        status = 'Code incorrect ou une erreur s\'est produite !';
      });
      print(status);
    }).then((user) async {
      setState(() {
        status = 'Authentification réussie';
      });
      onAuthenticationSuccessful(user);
    });
  }

  void phoneSignin() async {
    codeSent(String verificationId, [int? forceResendingToken]) async {
      actualCode = verificationId;
      setState(() {
        print('Code envoyé à $widget.phone');
        status = "\nEntrez le code envoyé à ${widget.phone}";
      });
    }

    verificationFailed(FirebaseAuthException authException) {
      setState(() {
        status = '${authException.message}';
        print("Message d'erreur : $status");
        if (authException.message!.contains('not authorized')) {
          status =
              'Quelque chose s\'est mal passé, veuillez réessayer plus tard';
        } else if (authException.message!.contains('Network')) {
          status = 'Veuillez vérifier votre connexion Internet et réessayer';
        } else {
          status =
              'Quelque chose s\'est mal passé, veuillez réessayer plus tard';
        }
      });
    }

    verificationCompleted(AuthCredential auth) {
      setState(() {
        status = 'Récupération automatique du code de vérification';
      });
      _auth.signInWithCredential(auth).then((UserCredential? value) {
        if (value != null && value.user != null) {
          setState(() {
            status = 'Authentification réussie';
          });
          onAuthenticationSuccessful(value);
        } else {
          setState(() {
            status = 'Code invalide / authentification invalide';
          });
        }
      }).catchError((error) {
        setState(() {
          status =
              'Quelque chose s\'est mal passé, veuillez réessayer plus tard';
        });
      });
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {
        actualCode = verificationId;
        setState(() {
          status = "\nDélai de récupération automatique dépassé";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(height: height / 20),
          Center(
            child: Text(
              "Vérification",
              style: GoogleFonts.lora(
                  textStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 35,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: status == ''
                  ? CircularProgressIndicator(
                      backgroundColor: AppColors.secondary,
                    )
                  : Text(
                      status,
                      style: GoogleFonts.lora(
                          textStyle: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 25,
                              fontWeight: FontWeight.w600)),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          Expanded(
            child: OTPTextField(
              length: 6,
              width: MediaQuery.of(context).size.width,
              style: TextStyle(
                  fontSize: 28,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.underline,
              onCompleted: (pin) {
                setState(() {
                  _signInWithPhoneNumber(pin);
                });
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: AppColors.tertiary,
                  height: 300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
