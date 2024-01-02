// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:eventos_partenaires/config/config.dart';

class PassesAlotted extends StatefulWidget {
  final bool isOnline;
  final String eventCode;
  final double price;
  final bool isPaid;
  PassesAlotted(this.eventCode, this.isOnline, this.price, this.isPaid);
  @override
  _PassesAlottedState createState() => _PassesAlottedState();
}

class _PassesAlottedState extends State<PassesAlotted> {
  var firestore = FirebaseFirestore.instance;
  late Future<List<QueryDocumentSnapshot>> users;
  Future getData() async {
    if (!widget.isOnline) {
      final QuerySnapshot joinedGuests = await firestore
          .collection('events')
          .doc(widget.eventCode)
          .collection('guests')
          .get();
      return joinedGuests.docs;
    } else {
      final QuerySnapshot joinedGuests = await firestore
          .collection('OnlineEvents')
          .doc(widget.eventCode)
          .collection('guests')
          .get();
      return joinedGuests.docs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participants')),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    SpinKitChasingDots(color: AppColors.secondary, size: 20));
          } else if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                  child: Text('Personne n\'a encore rejoint  :('));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.pink[50],
                      child: ListTile(
                        title: Text(
                            "${snapshot.data[index]['name']} (${snapshot.data[index]['passCode']})"),
                        subtitle: Text(
                            "${snapshot.data[index]['phone'] ?? snapshot.data[index]['email']}"),
                        trailing: widget.isPaid
                            ? Text(
                                "${snapshot.data[index]['ticketPrice']}*${snapshot.data[index]['ticketCount']}= F ${snapshot.data[index]['ticketCount'] * snapshot.data[index]['ticketPrice']}")
                            : Text('X ${snapshot.data[index]['ticketCount']}'),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('assets/NoOne.json'),
                const SizedBox(height: 20),
                Text('Aucun participant!',
                    style: GoogleFonts.novaRound(
                        textStyle: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tip: Utilisez le bouton Partager sur la page de détails de l\'événement afin que davantage de personnes puissent obtenir des tickets.',
                    style: GoogleFonts.novaRound(
                        textStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ScannedList extends StatefulWidget {
  final String eventCode;
  final bool isOnline;
  const ScannedList(this.eventCode, this.isOnline, {super.key});
  @override
  _ScannedListState createState() => _ScannedListState();
}

class _ScannedListState extends State<ScannedList> {
  var firestore = FirebaseFirestore.instance;
  late Future<List<DocumentSnapshot>> users;
  Future getData() async {
    if (!widget.isOnline) {
      final QuerySnapshot result = await firestore
          .collection('events')
          .doc(widget.eventCode)
          .collection('guests')
          .where('Scanned', isEqualTo: true)
          .get();
      return result.docs;
    } else {
      final QuerySnapshot result = await firestore
          .collection('events')
          .doc(widget.eventCode)
          .collection('guests')
          .where('Scanned', isEqualTo: true)
          .get();
      return result.docs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pass Scannés')),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitChasingDots(
                  color: AppColors.secondary,
                  size: 20,
                ),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(
                  child: Text('Pas encore de pass scanné :('),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          "${snapshot.data[index].data()['name']}",
                        ),
                        trailing: Text(
                          "X ${snapshot.data[index].data()['ticketCount']}",
                        ),
                        subtitle: Text(
                            "${snapshot.data[index].data()['phone'] ?? snapshot.data[index].data()['email']}"),
                      );
                    });
              }
            } else
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/NoOne.json',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pas encore de ticket scanné',
                    style: GoogleFonts.novaRound(
                        textStyle: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              );
          }),
    );
  }
}
