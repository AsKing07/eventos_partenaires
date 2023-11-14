// ignore_for_file: use_build_context_synchronously

import 'package:eventos_partenaires/config/config.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:lottie/lottie.dart';

class ScanPass extends StatefulWidget {
  final String eventCode;
  final bool isOnline;
  const ScanPass(this.eventCode, this.isOnline, {super.key});
  @override
  _ScanPassState createState() => _ScanPassState();
}

class _ScanPassState extends State<ScanPass> {
  void scanPass(BuildContext contextMain) async {
    if (widget.isOnline) {}
    //res représente l'information contenu dans le code QR. Donc le code du PASS
    String res = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'Stop Scan', true, ScanMode.QR);
    final x = await FirebaseFirestore.instance
        .collection(widget.isOnline ? 'OnlineEvents' : 'events')
        .doc(widget.eventCode)
        .collection('guests')
        .doc(res)
        .get();
    if (x.exists) {
      if (x['Scanned'] == false) {
        FirebaseFirestore.instance
            .collection(widget.isOnline ? 'OnlineEvents' : 'events')
            .doc(widget.eventCode)
            .collection('guests')
            .doc(res)
            .update({'Scanned': true});
        FirebaseFirestore.instance
            .collection(widget.isOnline ? 'OnlineEvents' : 'events')
            .doc(widget.eventCode)
            .update({'scanDone': FieldValue.increment(x['ticketCount'])});
        showDialog(
            context: contextMain,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                scrollable: true,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      scanPass(contextMain);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                    ),
                    child: const Text('Scanner Plus'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                    ),
                    child: const Text('Arreter le Scan'),
                  ),
                ],
                title: const Center(
                    child: Text("Pass scanné",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold))),
                content: Container(
                    child: Column(
                  children: [
                    Lottie.asset('assets/done.json', repeat: false),
                    const SizedBox(height: 10),
                    Text("Permettre  ${x['ticketCount']} entrée(s)",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
              );
            });
      } else {
        showDialog(
            context: contextMain,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                scrollable: true,
                title: const Center(
                    child: Text(
                  "Pass déjà Scanné(utilisé)",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 24),
                )),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      scanPass(contextMain);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                    ),
                    child: const Text('Scanner Plus'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                    ),
                    child: const Text('Arreter le Scann'),
                  ),
                ],
                content: Container(
                    child: Column(
                  children: [
                    Lottie.asset('assets/failed.json'),
                    const SizedBox(height: 10),
                    const Text("Entrée non permise",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
              );
            });
      }
    }
    if (x.exists == false) {
      showDialog(
          context: contextMain,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              scrollable: true,
              title: const Center(
                  child: Text(
                "Passe introuvable dans les enregistrements",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 22),
                textAlign: TextAlign.center,
              )),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    scanPass(contextMain);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                  ),
                  child: const Text('Scanner plus'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.tertiary,
                  ),
                  child: const Text('Arrêter la numérisation'),
                ),
              ],
              content: Container(
                  child: Column(
                children: [
                  Lottie.asset('assets/failed.json'),
                  const SizedBox(height: 10),
                  const Text("Entrée non permise",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              )),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Center(
              child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
            child: Text(
              'Instructions pour le scan QR ',
              style: GoogleFonts.varelaRound(
                  textStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Divider(
              color: AppColors.secondary,
              height: 15,
              thickness: 2,
            ),
          ),
          Lottie.asset('assets/qrAnim.json'),
          const SizedBox(height: 10),
          const Text(
            '1. Tenez le téléphone en position verticale.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            '2.Centrez le code QR sur le cadre de la caméra',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            '3.Attendez que le pass soit scanné',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              scanPass(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.tertiary,
            ),
            child: const Text(
              'Démarrer le Scan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ))),
    );
  }
}
