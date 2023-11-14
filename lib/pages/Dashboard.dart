// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventos_partenaires/Widgets/colorCard.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/pages/lists.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  bool isTeam;
  DocumentSnapshot post;
  Dashboard(this.isTeam, this.post, {super.key});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    double div = widget.post['joined'] / widget.post['maxAttendee'] * 100;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 13.0,
                animation: true,
                percent: widget.post['joined'] / widget.post['maxAttendee'],
                center: Text(
                  '${div.toStringAsFixed(2)} %',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                footer: const Text(
                  "Tickets vendus",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.amber),
            const SizedBox(height: 10),
            widget.post['isPaid']
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      colorCard(
                          "Revenu Brut",
                          widget.post['amountEarned'].toDouble(),
                          1,
                          context,
                          const Color(0xFF1b5bff)),
                      colorCard(
                          "Revenu Net",
                          widget.post['amountEarned'] * 92 / 100,
                          1,
                          context,
                          const Color(0xFFff3f5e)),
                    ],
                  )
                : Container(),
            const SizedBox(height: 20),
            Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(12.0),
              shadowColor: AppColors.secondary,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PassesAlotted(
                        widget.post['eventCode'],
                        widget.post['isOnline'],
                        widget.post['ticketPrice'],
                        widget.post['isPaid']);
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Participants',
                                style: TextStyle(color: AppColors.primary)),
                            Text(
                                NumberFormat.compact()
                                    .format(widget.post['joined']),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30.0))
                          ],
                        ),
                        Material(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24.0),
                            child: const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.people,
                                  color: Colors.white, size: 30.0),
                            )))
                      ]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(12.0),
              shadowColor: AppColors.secondary,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ScannedList(
                        widget.post['eventCode'], widget.post['isOnline']);
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Pass scannés',
                                style: TextStyle(color: AppColors.primary)),
                            StreamBuilder<DocumentSnapshot>(
                                stream: widget.post['isOnline']
                                    ? FirebaseFirestore.instance
                                        .collection('OnlineEvents')
                                        .doc(widget.post['eventCode'])
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('events')
                                        .doc(widget.post['eventCode'])
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Loading..',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 30.0));
                                  }
                                  return Text(
                                      NumberFormat.compact()
                                          .format(snapshot.data!['scanDone']),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 30.0));
                                })
                          ],
                        ),
                        Material(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24.0),
                            child: const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.confirmation_number,
                                  color: Colors.white, size: 30.0),
                            )))
                      ]),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
