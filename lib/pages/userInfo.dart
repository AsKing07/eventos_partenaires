import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/Methods/getUserId.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/Methods/firebaseAdd.dart';
import 'package:eventos_partenaires/Methods/getUserId.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/pages/loginui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  final String phone, name, email;
  final bool isGmail;
  UserInfoPage(this.phone, this.email, this.name, this.isGmail);
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  // late String _name, _country;
  late String _name, _country;

  bool isBenin = false;
  bool isOutside = false;
  final TextEditingController _nameController = TextEditingController();

  onCountrySelect(int x) {
    if (x == 0) {
      setState(() {
        isBenin = true;
        isOutside = false;
      });
    } else {
      setState(() {
        isOutside = true;
        isBenin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'utilisateur"),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  'assets/userInfo.svg',
                  height: MediaQuery.of(context).size.height / 3.5,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Où habitez-vous ?',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    onCountrySelect(0);
                  },
                  child: Card(
                    elevation: 2,
                    color: isBenin
                        ? AppColors.tertiary.withOpacity(1)
                        : Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          'Bénin',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    onCountrySelect(1);
                  },
                  child: Card(
                    elevation: 2,
                    color: isOutside
                        ? AppColors.tertiary.withOpacity(1)
                        : Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          'Hors du Bénin',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              !widget.isGmail
                  ? TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Entrez votre nom complet',
                      ),
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                    )
                  : Container(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (!isOutside && !isBenin) {
                    Fluttertoast.showToast(
                      msg: 'Sélectionnez un emplacement !',
                      backgroundColor: Colors.redAccent,
                    );
                  } else if (!widget.isGmail &&
                      _nameController.text.trim() == '') {
                    Fluttertoast.showToast(
                      msg: 'Entrez un nom valide',
                      backgroundColor: Colors.redAccent,
                    );
                  } else {
                    String uid = await getCurrentUid();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('login', true);
                    String name =
                        widget.isGmail ? widget.name : _nameController.text;
                    FirebaseAdd().addUser(
                        name, widget.email, widget.phone, uid, isBenin);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        ModalRoute.withName('login'));
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  primary: AppColors.secondary,
                  onPrimary: AppColors.primary,
                ),
                child: const Text(
                  "Suivant",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
