// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventos_partenaires/pages/Announcements.dart';
import 'package:eventos_partenaires/pages/Dashboard.dart';
import 'package:eventos_partenaires/models/user.dart';
import 'package:eventos_partenaires/pages/Team.dart';
import 'package:eventos_partenaires/config/size.dart';
import 'package:eventos_partenaires/pages/edit_event.dart';
import 'package:eventos_partenaires/pages/lists.dart';
import 'package:eventos_partenaires/pages/scanPass.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Pass.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:readmore/readmore.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailPage extends StatefulWidget {
  final DocumentSnapshot post;
  final String uid;
  final Function rebuild;
  DetailPage(this.post, this.uid, this.rebuild);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController eventCodeController = TextEditingController();
  late String writtenCode, passCode;
  final _key = GlobalKey();
  int page = 0;
  late bool isTeam;

  Future helper() async {
    final x = await FirebaseFirestore.instance.collection('helpers').get();
    return x.docs;
  }

  void isTeamMember() async {
    final x = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('eventsHosted')
        .doc(widget.post['eventCode'])
        .get();
    isTeam = x.data()!['isTeam'];
  }

  void showPass() async {
    late String passCode;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('eventJoined')
        .where('eventCode', isEqualTo: widget.post['eventCode'])
        .get()
        .then((value) {
      passCode = value.docs.elementAt(0).data()['passCode'];
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Pass(passCode, widget.post);
    }));
  }

  void getPass(BuildContext context, double height) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            scrollable: true,
            backgroundColor: AppColors.secondary,
            title: const Center(
              child: Text(
                "Obtenir un Pass",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30),
              ),
            ),
            content: Container(
              height: height / 5,
              child: Column(
                children: [
                  TextField(
                    controller: eventCodeController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                    cursorColor: AppColors.primary,
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: "Entrez le code de l'évènement"),
                  ),
                  Expanded(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final x = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .collection('eventJoined')
                              .doc(widget.post['eventCode'])
                              .get();
                          if (widget.post['eventCode'] !=
                              eventCodeController.text) {
                            Fluttertoast.showToast(
                                msg: "Code incorrect saisi",
                                backgroundColor: Colors.red,
                                textColor: Colors.white);
                          } else if (widget.post['joined'] >=
                              widget.post['maxAttendee'])
                            // ignore: curly_braces_in_flow_control_structures
                            Fluttertoast.showToast(
                                msg: "Événement complet",
                                backgroundColor: Colors.red,
                                textColor: Colors.white);
                          else if (x.exists) {
                            Fluttertoast.showToast(
                                msg: "Déjà inscrit à l'événement",
                                backgroundColor: Colors.red,
                                textColor: Colors.white);
                          } else {
                            passCode = randomAlphaNumeric(6);
                            User user;
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .get();
                            user = User.fromDocument(userDoc);
                            FirebaseFirestore.instance
                                .collection("events")
                                .doc(widget.post['eventCode'])
                                .collection('guests')
                                .doc(passCode)
                                .set({
                              'user': user.uid,
                              'phone': user.phone,
                              'email': user.email,
                              'name': user.name,
                              'passCode': passCode,
                              'Scanned': false
                            });
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('eventJoined')
                                .doc(widget.post['eventCode'])
                                .set({
                              'eventCode': widget.post['eventCode'],
                              'passCode': passCode
                            });
                            FirebaseFirestore.instance
                                .collection('events')
                                .doc(widget.post['eventCode'])
                                .update({'joined': widget.post['joined'] + 1});
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Pass(passCode, widget.post);
                            }));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          elevation: 10,
                        ),
                        child: Text("Obtenir un Pass",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: AppColors.primary)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }).then((value) {
      eventCodeController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    isTeamMember();
  }

  @override
  Widget build(BuildContext context) {
    double width = SizeConfig.getWidth(context);
    double height = SizeConfig.getHeight(context);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.edit),
              label: 'Event Info',
              backgroundColor: AppColors.primary,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: 'Dashboard',
              backgroundColor: AppColors.primary,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.qrcode),
              label: 'Enregistrement',
              backgroundColor: AppColors.primary,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.users),
              label: 'Team',
              backgroundColor: AppColors.primary,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.bullhorn),
              label: 'Annonces',
              backgroundColor: AppColors.primary,
            ),
          ],
          elevation: 5,
          unselectedItemColor: AppColors.secondary,
          currentIndex: page,
          backgroundColor: Colors.purple,
          selectedItemColor: AppColors.tertiary,
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() {
              page = index;
            });
          },
        ),
        appBar: AppBar(
          title: Text(
            page == 0
                ? "Details Evenement"
                : page == 1
                    ? 'Dashboard'
                    : page == 2
                        ? 'Scanner Pass'
                        : page == 3
                            ? 'Team'
                            : 'Annonces',
          ),
          centerTitle: true,
          actions: <Widget>[
            page == 3
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        final dynamic tooltip = _key.currentState;
                        tooltip.ensureTooltipVisible();
                      },
                      child: Tooltip(
                        key: _key,
                        padding: const EdgeInsets.all(20),
                        preferBelow: true,
                        showDuration: const Duration(seconds: 5),
                        message:
                            'Que peuvent faire les membres de l’équipe?\n\n'
                            '1. Ils peuvent scanner les tickets (enregistrer les invités)\n'
                            '2. Ils peuvent faire des annonces\n'
                            '3. Ils ne peuvent pas modifier les détails de l\'événement',
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.tertiary),
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        verticalOffset: 10,
                        child: Icon(
                          Icons.info,
                          color: AppColors.tertiary,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
          backgroundColor: AppColors.primary,
        ),
        body: page == 0
            ? SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: width / 25, vertical: height * 0.02),
                  child: Column(
                    children: [
                      Container(
                        height: height / 3.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              widget.post['eventBanner'],
                              width: width / 2.8,
                              height: height / 3.6,
                              fit: BoxFit.fitHeight,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 12, 10, 10),
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            "${widget.post['eventName']}",
                                            style: GoogleFonts.varelaRound(
                                                textStyle: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22))),
                                      ),
                                      const SizedBox(height: 5),
                                      Column(
                                        children: [
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                DateFormat('hh:mm a').format(
                                                    widget.post['eventDateTime']
                                                        .toDate()),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18),
                                              )),
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                DateFormat('EEE, d MMMM yyyy')
                                                    .format(widget
                                                        .post['eventDateTime']
                                                        .toDate()),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                              'Event Code: ${widget.post['eventCode']}',
                              style: GoogleFonts.varelaRound(
                                  textStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18)),
                            )),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              color: AppColors.primary,
                              splashColor: AppColors.primary,
                              highlightColor: AppColors.primary,
                              onPressed: () {
                                if (DateTime.now().isBefore(widget
                                        .post['eventDateTime']
                                        .toDate()) &&
                                    !isTeam) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditPage(
                                              widget.post, widget.rebuild)));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Vous ne pouvez pas modifier ;)',
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      gravity: ToastGravity.TOP);
                                }
                              },
                            ),
                            IconButton(
                                color: AppColors.primary,
                                splashColor: AppColors.primary,
                                highlightColor: AppColors.primary,
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  await FlutterShare.share(
                                      title:
                                          'Obtenez un ticket pour ${widget.post['eventName']}',
                                      text:
                                          'Obtenez des tickets pour ${widget.post['eventName']} se déroulant le ${DateFormat('dd-MM-yyyy AT hh:mm a').format(widget.post['eventDateTime'].toDate())}\n\n Code Evenement:'
                                          '${widget.post['eventCode']}'
                                          '\n\n Ouvrez l\'application:\nhttps://play.google.com/store/apps/ \n\nEventOs',
                                      linkUrl: '',
                                      chooserTitle:
                                          'Obtenir des tickets pour ${widget.post['eventName']}');
                                }),
                          ],
                        ),
                      ),
                      !widget.post['isOnline']
                          ? const SizedBox(
                              height: 15,
                            )
                          : Container(),
                      !widget.post['isOnline']
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Addresse',
                                style: GoogleFonts.varelaRound(
                                    textStyle: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24)),
                              ),
                            )
                          : Container(),
                      !widget.post['isOnline']
                          ? Divider(
                              color: AppColors.secondary,
                              height: 10,
                              thickness: 2,
                            )
                          : Container(),
                      !widget.post['isOnline']
                          ? const SizedBox(height: 15)
                          : Container(),
                      !widget.post['isOnline']
                          ? Text(
                              ' ${widget.post['position']} \n ${widget.post['eventAddress']} ',
                              style: const TextStyle(fontSize: 18),
                            )
                          : Container(),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Description',
                          style: GoogleFonts.varelaRound(
                              textStyle: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24)),
                        ),
                      ),
                      Divider(
                        color: AppColors.secondary,
                        height: 10,
                        thickness: 2,
                      ),
                      const SizedBox(height: 15),
                      ReadMoreText(
                        '${widget.post['eventDescription']}',
                        trimLines: 10,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        trimCollapsedText: 'Voir Plus',
                        trimExpandedText: 'Voir moins',
                        moreStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Aide personnelle',
                          style: GoogleFonts.varelaRound(
                              textStyle: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24)),
                        ),
                      ),
                      Divider(
                        color: AppColors.secondary,
                        height: 10,
                        thickness: 2,
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: helper(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting ||
                              snap.data == null) {
                            return Container();
                          } else {
                            return ElevatedButton(
                              onPressed: () {
                                try {
                                  launch(
                                      '${snap.data[widget.post['helper']].data()['contact']}');
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg:
                                        'Impossible d\'effectuer cette action pour le moment. Si le problème perssiste, contactez-nous via les paramètres',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[700],
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                              ),
                              child: Text(
                                'Contacter ${snap.data[widget.post['helper']].data()['name']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            : page == 1
                ? Dashboard(isTeam, widget.post)
                : page == 2
                    ? ScanPass(
                        widget.post['eventCode'], widget.post['isOnline'])
                    : page == 3
                        ? TeamPage(widget.post['eventCode'], isTeam,
                            widget.post['isOnline'])
                        : Announcements(widget.post['eventCode'], true,
                            widget.post['isOnline'], widget.post['eventName']));
  }
}
