// ignore_for_file: use_build_context_synchronously

import 'package:eventos_partenaires/pages/AboutUs.dart';
import 'package:eventos_partenaires/pages/Policy.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventos_partenaires/pages/createEvent.dart';
import 'package:eventos_partenaires/pages/loginui.dart';
import 'package:eventos_partenaires/methods/getUserId.dart';
import 'package:eventos_partenaires/methods/googleSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventos_partenaires/Widgets/eventCard.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/config/size.dart';

import 'package:skeleton_text/skeleton_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var firestore = FirebaseFirestore.instance;
  late String uid = '';
  int _selectedIndex = 0;

  Future<void> getUser() async {
    uid = await getCurrentUid();
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  rebuild() {
    setState(() {});
  }

  Future getEvents(int index) async {
    if (uid.isNotEmpty) {
      List<String> eventCodes = [];
      final QuerySnapshot result = await firestore
          .collection('users')
          .doc(uid)
          .collection('eventsHosted')
          .get();
      for (var element in result.docs) {
        eventCodes.add(element['eventCode']);
      }
      if (index == 0) {
        final QuerySnapshot hostedEventDetails = await firestore
            .collection('events')
            .orderBy('eventDateTime', descending: false)
            .where("eventCode", whereIn: eventCodes)
            .get();
        return hostedEventDetails.docs;
      } else {
        final QuerySnapshot hostedEventDetails = await firestore
            .collection('OnlineEvents')
            .orderBy('eventDateTime', descending: false)
            .where("eventCode", whereIn: eventCodes)
            .get();
        return hostedEventDetails.docs;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primary,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.calendar),
              label: 'Evenements en Présentiel',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.laptop),
              label: 'Evenements en ligne',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.tertiary,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateEvent(uid!)));
          },
          label: const Text(
            "Organiser un événement",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(
                  width / 15, height / 15, width / 15, height / 50),
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 60,
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_horiz,
                        color: AppColors.primary, size: 30),
                    color: AppColors.primary,
                    itemBuilder: (context) {
                      var liste = <PopupMenuEntry<Object>>[];
                      liste.add(
                        PopupMenuItem(
                          child: Text(
                            "Profil",
                            style: TextStyle(color: AppColors.tertiary),
                          ),
                        ),
                      );
                      liste.add(
                        const PopupMenuDivider(
                          height: 4,
                        ),
                      );
                      liste.add(
                        PopupMenuItem(
                          value: 2,
                          child: Text(
                            "Déconnexion",
                            style: TextStyle(color: AppColors.tertiary),
                          ),
                        ),
                      );
                      liste.add(
                        PopupMenuItem(
                          value: 3,
                          child: Text(
                            "A Propos de Nous",
                            style: TextStyle(color: AppColors.tertiary),
                          ),
                        ),
                      );
                      liste.add(
                        PopupMenuItem(
                          value: 4,
                          child: Text(
                            "Politiques de Confidentialité",
                            style: TextStyle(color: AppColors.tertiary),
                          ),
                        ),
                      );
                      return liste;
                    },
                    onSelected: (value) async {
                      if (value == 2) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.clear();
                        signOut();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            ModalRoute.withName('homepage'));
                      }
                      if (value == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutUs()),
                        );
                      }
                      if (value == 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicy()),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Evenements organisés",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.redAccent),
                ),
              ),
            ),
            uid.isNotEmpty
                ? FutureBuilder(
                    future: getEvents(_selectedIndex),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Expanded(
                            child: Center(
                                child: SpinKitChasingDots(
                                    color: AppColors.secondary, size: 40)));
                      } else if (snapshot.data == null) {
                        return Column(
                          children: [
                            Container(
                              width: width,
                              height: height / 2,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SvgPicture.asset('assets/event.svg',
                                      semanticsLabel:
                                          'Illustration de l\'événement'),
                                ),
                              ),
                            ),
                            SizedBox(height: height / 20),
                            const Text("Rien à montrer ici :(")
                          ],
                        );
                      } else {
                        if (snapshot.data.length == 0) {
                          return Column(
                            children: [
                              Container(
                                width: width,
                                height: height / 2,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SvgPicture.asset('assets/event.svg',
                                        semanticsLabel:
                                            'Illustration de l\'événement'),
                                  ),
                                ),
                              ),
                              SizedBox(height: height / 20),
                              const Text("Rien à montrer ici :(")
                            ],
                          );
                        } else {
                          return Expanded(
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return eventCard(snapshot.data[index], height,
                                      width, context, rebuild);
                                }),
                          );
                        }
                      }
                    })
                : Expanded(
                    child: Center(
                        child: SpinKitChasingDots(
                            color: AppColors.secondary, size: 40))),
          ],
        ));
  }
}
