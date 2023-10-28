import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:flutter_svg/svg.dart';
import 'package:eventos_partenaires/methods/getUserId.dart';

class TeamPage extends StatefulWidget {
  final String eventCode;
  final bool isTeam;
  final bool isOnline;
  TeamPage(this.eventCode, this.isTeam, this.isOnline);
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  TextEditingController controller = TextEditingController();
  Future<List<DocumentSnapshot>> getTeamList() async {
    final x = await FirebaseFirestore.instance
        .collection(widget.isOnline ? 'OnlineEvents' : 'events')
        .doc(widget.eventCode)
        .collection('team')
        .get();
    return x.docs;
  }

  removeMember(String removeUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(removeUid)
        .collection('eventsHosted')
        .doc(widget.eventCode)
        .delete();
    await FirebaseFirestore.instance
        .collection(widget.isOnline ? 'OnlineEvents' : 'events')
        .doc(widget.eventCode)
        .collection('team')
        .doc(removeUid)
        .delete();
    Fluttertoast.showToast(
        msg: 'Retiré de l\'équipe',
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.green);
    setState(() {});
  }

  addMember(String user) async {
    String uid = await getCurrentUid();
    final i =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final x = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.toLowerCase())
        .get();
    final y = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: user.toLowerCase())
        .get();
    if (i['email'] == user || i['phoneNumber'] == user) {
      Fluttertoast.showToast(
          msg: 'Vous ne pouvez pas vous ajouter à l\'équipe',
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP);
    } else if (x.docs.isEmpty && y.docs.isEmpty) {
      Fluttertoast.showToast(
          msg:
              'Aucun utilisateur trouvé, essayez d\'utiliser une autre adresse e-mail ou un autre numéro de téléphone',
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP);
    } else {
      if (x.docs.isNotEmpty && y.docs.isEmpty) {
        final m = await FirebaseFirestore.instance
            .collection(widget.isOnline ? 'OnlineEvents' : 'events')
            .doc(widget.eventCode)
            .collection('team')
            .doc(x.docs[0]['uid'])
            .get();
        if (m.exists) {
          Fluttertoast.showToast(
              msg: '${x.docs[0]['name']} est déjà dans votre équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
              gravity: ToastGravity.TOP);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(x.docs[0]['uid'])
              .collection('eventsHosted')
              .doc(widget.eventCode)
              .set({'eventCode': widget.eventCode, 'isTeam': true});
          await FirebaseFirestore.instance
              .collection(widget.isOnline ? 'OnlineEvents' : 'events')
              .doc(widget.eventCode)
              .collection('team')
              .doc(x.docs[0]['uid'])
              .set({
            'email': x.docs[0]['email'],
            'name': x.docs[0]['name'],
            'phoneNumber': x.docs[0]['phoneNumber'],
            'uid': x.docs[0]['uid']
          });
          Fluttertoast.showToast(
              msg: '${x.docs[0]['name']} à été ajouté à l\'équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP);
          setState(() {});
        }
      } else if (y.docs.isNotEmpty && x.docs.isEmpty) {
        final a = await FirebaseFirestore.instance
            .collection(widget.isOnline ? 'OnlineEvents' : 'events')
            .doc(widget.eventCode)
            .collection('team')
            .doc(y.docs[0]['uid'])
            .get();
        if (a.exists) {
          Fluttertoast.showToast(
              msg: '${y.docs[0]['name']} est déjà dans votre équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
              gravity: ToastGravity.TOP);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(y.docs[0]['uid'])
              .collection('eventsHosted')
              .doc(widget.eventCode)
              .set({'eventCode': widget.eventCode, 'isTeam': true});
          await FirebaseFirestore.instance
              .collection(widget.isOnline ? 'OnlineEvents' : 'events')
              .doc(widget.eventCode)
              .collection('team')
              .doc(y.docs[0]['uid'])
              .set({
            'email': y.docs[0]['email'],
            'name': y.docs[0]['name'],
            'phoneNumber': y.docs[0]['phoneNumber'],
            'uid': y.docs[0]['uid']
          });
          Fluttertoast.showToast(
              msg: '${y.docs[0]['name']} a été ajouté à votre équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP);
          setState(() {});
        }
      } else {
        final b = await FirebaseFirestore.instance
            .collection(widget.isOnline ? 'OnlineEvents' : 'events')
            .doc(widget.eventCode)
            .collection('team')
            .doc(x.docs[0]['uid'])
            .get();
        if (b.exists) {
          Fluttertoast.showToast(
              msg: '${x.docs[0]['name']} est déjà dans votre équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
              gravity: ToastGravity.TOP);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(x.docs[0]['uid'])
              .collection('eventsHosted')
              .doc(widget.eventCode)
              .set({'eventCode': widget.eventCode, 'isTeam': true});
          await FirebaseFirestore.instance
              .collection(widget.isOnline ? 'OnlineEvents' : 'events')
              .doc(widget.eventCode)
              .collection('team')
              .doc(x.docs[0]['uid'])
              .set({
            'email': x.docs[0]['email'],
            'name': x.docs[0]['name'],
            'phoneNumber': x.docs[0]['phoneNumber'],
            'uid': x.docs[0]['uid']
          });
          Fluttertoast.showToast(
              msg: '${x.docs[0]['name']} a été à votre équipe',
              textColor: Colors.white,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP);
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: FutureBuilder(
        future: getTeamList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: SpinKitChasingDots(
              color: AppColors.secondary,
              size: 40,
            ));
          } else if (!snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset('assets/team.svg'),
                      const SizedBox(
                        height: 20,
                      ),
                      Text('Pas encore de membre dans votre équipe',
                          style: GoogleFonts.alata(
                              fontWeight: FontWeight.w600, fontSize: 20))
                    ]),
              ),
            );
          } else {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/team.svg',
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text('Pas encore de membre dans votre équipe',
                            style: GoogleFonts.alata(
                                fontWeight: FontWeight.w600, fontSize: 20)),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              enableDrag: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.0)),
                              ),
                              backgroundColor: AppColors.tertiary,
                              builder: (BuildContext bc) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    left: 20,
                                    top: 20,
                                    right: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextField(
                                        autofocus: true,
                                        cursorColor: AppColors.primary,
                                        controller: controller,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText:
                                              'Email/Numéro de téléphone du membre de l\'équipe',
                                          helperText:
                                              'Entrez le numéro de téléphone avec le code pays',
                                          fillColor: AppColors.primary,
                                          focusColor: AppColors.primary,
                                          hintStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Align(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              addMember(controller.text),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    AppColors.primary),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    AppColors.secondary),
                                          ),
                                          child: const Text('Ajouter',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.tertiary),
                            overlayColor:
                                MaterialStateProperty.all(AppColors.primary),
                          ),
                          child: const Text('Ajouter un membre de l\'équipe',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                        )
                      ]),
                ),
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: ListTile(
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: !widget.isTeam
                                    ? () => removeMember(
                                        snapshot.data![index]['uid'])
                                    : null,
                                color: Colors.red,
                                splashColor: Colors.red,
                              ),
                              title: Text(
                                snapshot.data![index]['name'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(snapshot.data![index]['email'] ??
                                  snapshot.data![index]['phoneNumber']),
                            ),
                          );
                        }),
                  ),
                  !widget.isTeam
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                              child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.tertiary,
                            child: IconButton(
                              iconSize: 30,
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    enableDrag: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0))),
                                    backgroundColor: AppColors.tertiary,
                                    builder: (BuildContext bc) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.5,
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                            left: 20,
                                            top: 20,
                                            right: 20),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              TextField(
                                                autofocus: true,
                                                cursorColor: AppColors.primary,
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              AppColors.primary,
                                                          width: 3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: AppColors
                                                                  .primary,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                  hintText:
                                                      'Email/numéro de téléphone du membre de l\'équipe',
                                                  fillColor: AppColors.primary,
                                                  focusColor: AppColors.primary,
                                                  helperText:
                                                      'Saisissez le numéro de téléphone, y compris l\'indicatif du pays',
                                                  hintStyle: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Align(
                                                  child: ElevatedButton(
                                                onPressed: () =>
                                                    addMember(controller.text),
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  disabledForegroundColor:
                                                      AppColors.secondary
                                                          .withOpacity(0.38),
                                                  disabledBackgroundColor:
                                                      AppColors.secondary
                                                          .withOpacity(0.12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Ajouter',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              )),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                            ]),
                                      );
                                    });
                              },
                              splashColor: AppColors.primary,
                              color: Colors.black,
                            ),
                          )),
                        )
                      : Container()
                ],
              );
            }
          }
        },
      ),
    );
  }
}
