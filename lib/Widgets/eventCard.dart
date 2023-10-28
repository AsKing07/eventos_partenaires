// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventos_partenaires/Methods/getUserId.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/pages/EventDetails.dart';
import 'package:skeleton_text/skeleton_text.dart';

Widget eventCard(DocumentSnapshot event, double height, double width,
    BuildContext context, Function rebuild) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.02),
      height: height * 0.3,
      child: InkWell(
        onTap: () async {
          String uid = await getCurrentUid();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DetailPage(event, uid, rebuild);
          }));
        },
        child: Card(
          color: Colors.deepPurple[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: CachedNetworkImage(
                            imageUrl: event['eventBanner'],
                            fit: BoxFit.fitHeight,
                            width: width * 0.3,
                            height: height * 0.3,
                            placeholder: (context, url) => SkeletonAnimation(
                              child: Container(
                                width: width * 0.3,
                                height: height * 0.3,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "${event['eventName']}",
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: AppColors.primary)),
                                    textAlign: TextAlign.start,
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        DateFormat('hh:mm a').format(
                                            event['eventDateTime'].toDate()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        DateFormat('EEE, d MMMM yyyy').format(
                                            event['eventDateTime'].toDate()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: width,
                      color: AppColors.secondary,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 5),
                        child: Text(
                            "${event['isOnline'] ? 'Evenement en ligne' : event['eventAddress']}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
              ]),
        ),
      ),
    ),
  );
}
