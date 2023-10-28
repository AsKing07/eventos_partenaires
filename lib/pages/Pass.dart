import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventos_partenaires/config/size.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventos_partenaires/Widgets/clipper.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:social_media_buttons/social_media_buttons.dart';

class Pass extends StatefulWidget {
  final String passCode;
  final DocumentSnapshot details;
  Pass(this.passCode, this.details);
  @override
  _PassState createState() => _PassState();
}

class _PassState extends State<Pass> {
  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                color: AppColors.secondary,
                height: 150,
              ),
            ),
          ),
          Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: width / 15, vertical: height / 15),
                    width: width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: "Event'",
                                style: GoogleFonts.lora(
                                    textStyle: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold))),
                            TextSpan(
                                text: "O",
                                style: GoogleFonts.lora(
                                    textStyle: TextStyle(
                                        color: Colors.pink[600],
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold))),
                            TextSpan(
                                text: "'s",
                                style: GoogleFonts.lora(
                                    textStyle: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold)))
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: width / 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: width / 1.8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 5),
                              Text(
                                "${widget.details['eventName']}",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "DATE & HEURE",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                '${DateFormat('dd-MM-yyyy, hh:mm a').format(widget.details['eventDateTime'].toDate())}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "PASS CODE",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${widget.passCode}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "ADDRESSE",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${widget.details['eventAddress']}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Image.network(
                            widget.details['eventBanner'],
                            height: height / 5,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: QrImageView(
                          data: widget.passCode,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Un Pass, une Entrée",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 25,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SocialMediaButton.facebook(
                          url: '',
                          size: 35,
                          color: AppColors.primary,
                        ),
                        SocialMediaButton.instagram(
                          url: 'https://www.instagram.com/',
                          size: 35,
                          color: AppColors.primary,
                        ),
                        SocialMediaButton.twitter(
                          url: '',
                          size: 35,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
