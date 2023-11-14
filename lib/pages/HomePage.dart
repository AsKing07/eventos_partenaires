// ignore_for_file: use_build_context_synchronously

import 'package:eventos_partenaires/pages/AboutUs.dart';
import 'package:eventos_partenaires/pages/Policy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:eventos_partenaires/pages/createEvent.dart';
import 'package:eventos_partenaires/pages/loginui.dart';
import 'package:eventos_partenaires/methods/getUserId.dart';
import 'package:eventos_partenaires/methods/googleSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventos_partenaires/Widgets/eventCard.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/config/size.dart';

import 'package:url_launcher/url_launcher.dart';

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
    User? user = FirebaseAuth.instance.currentUser;

    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    const String photUrl =
        "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg";
    String photoURL = user!.photoURL ?? photUrl;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
        ),
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
        drawer: GFDrawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              GFDrawerHeader(
                currentAccountPicture: GFAvatar(
                  radius: 80.0,
                  backgroundImage: NetworkImage(photoURL),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(user.displayName ?? ""),
                    Text(user.email ?? " "),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event, color: Colors.black),
                title: const Text('Participer à des évènements'),
                onTap: () {
                  //           //lien de l'application pour EventOs User

                  launchUrl(
                      Uri.https('play.google.com/store/apps/details?id='));
                },
              ),
              ListTile(
                leading: const Icon(Icons.policy, color: Colors.black),
                title: const Text('Politiques de Confidentialité'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.black),
                title: const Text('A Propos de l\'Application'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutUs()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text('Se Déconnecter'),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();
                  signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                      ModalRoute.withName('homepage'));
                },
              ),
            ],
          ),
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
