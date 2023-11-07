// ignore_for_file: unnecessary_null_comparison, unused_field

import 'package:flutter/material.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/config/size.dart';
import 'package:eventos_partenaires/Methods/googleSignIn.dart';
import '../Widgets/clipper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(children: <Widget>[
        SizedBox(
          height: height / 20,
        ),
        Expanded(
            child: Image.asset(
          'assets/logo.png',
          height: 70,
        )),
        Expanded(
          child: Center(
            child: RichText(
                text: TextSpan(children: <TextSpan>[
              TextSpan(
                  text: "Event",
                  style: GoogleFonts.lora(
                      textStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: 45,
                          fontWeight: FontWeight.bold))),
              TextSpan(
                  text: "OS",
                  style: GoogleFonts.lora(
                      textStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: 45,
                          fontWeight: FontWeight.bold))),
            ])),
          ),
        ),
        SizedBox(
          height: height / 20,
        ),
        SvgPicture.asset(
          'assets/login.svg',
          width: width,
          height: height / 3,
        ),
        SizedBox(height: height / 10),
        Column(
          children: <Widget>[
            SignInButton(
              Buttons.GoogleDark,
              onPressed: () {
                signInWithGoogle(context);
              },
              text: "Se connecter avec Google",
            ),
            const SizedBox(height: 10),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                color: AppColors.secondary,
                height: 300,
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.icon,
      required this.hint,
      this.obsecure = false,
      required this.validator,
      required this.controller,
      required this.maxLines,
      required this.minLines,
      required this.onSaved,
      required this.radius,
      required this.number,
      required this.color,
      required this.width,
      required this.onChanged});

  final TextEditingController controller;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;
  final int maxLines;
  final int minLines;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final bool number;
  final double radius;
  final Color color;
  final double width;

  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        onChanged: onChanged,
        onSaved: onSaved,
        validator: validator,
        maxLines: maxLines,
        minLines: minLines,
        obscureText: obsecure,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        style: TextStyle(fontSize: 20, color: AppColors.primary),
        decoration: InputDecoration(
            hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: color,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: color,
                width: width,
              ),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 25, right: 10),
              child: IconTheme(
                data: IconThemeData(color: AppColors.primary),
                child: icon,
              ),
            )),
      ),
    );
  }
}
