// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:eventos_partenaires/models/AnnouncementClass.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:eventos_partenaires/methods/firebaseAdd.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Announcements extends StatefulWidget {
  final bool isOwner;
  final String eventCode;
  final bool isOnline;
  final String eventName;
  const Announcements(
      this.eventCode, this.isOwner, this.isOnline, this.eventName,
      {super.key});
  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.isOwner
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateAnnouncement(widget.eventCode,
                          widget.isOnline, widget.eventName))),
              icon: const Icon(
                Icons.add,
              ),
              backgroundColor: AppColors.tertiary,
              splashColor: AppColors.secondary,
              label: Text("Annonce",
                  style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600))),
            )
          : Container(),
      body: StreamBuilder(
          stream: widget.isOnline
              ? FirebaseFirestore.instance
                  .collection("OnlineEvents")
                  .doc(widget.eventCode)
                  .collection("Announcements")
                  .orderBy('timestamp', descending: true)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.eventCode)
                  .collection("Announcements")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/NoOne.json",
                          width: MediaQuery.of(context).size.width * 0.8),
                      const SizedBox(height: 10),
                      Text(
                        'Pas encore d\'annonce!',
                        style: GoogleFonts.novaRound(
                            textStyle: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return announceWidget(
                            Announce.fromDocument(snapshot.data!.docs[index]),
                            widget.isOwner,
                            widget.eventCode,
                            widget.isOnline);
                      }),
                );
              }
            }
          }),
    );
  }
}

Widget announceWidget(
    Announce announce, bool isOwner, String eventCode, bool isOnline) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                timeago.format(
                    DateTime.parse("${announce.timestamp?.toDate()}"),
                    locale: "fr"),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              isOwner ? const SizedBox(width: 10) : Container(),
              isOwner
                  ? PopupMenuButton(
                      color: AppColors.secondary,
                      icon: const Icon(Icons.more_vert),
                      onSelected: (val) async {
                        if (val == 1) {
                          if (isOnline) {
                            await FirebaseFirestore.instance
                                .collection('OnlineEvents')
                                .doc(eventCode)
                                .collection('Announcements')
                                .doc(announce.id)
                                .delete();
                          } else {
                            await FirebaseFirestore.instance
                                .collection('events')
                                .doc(eventCode)
                                .collection('Announcements')
                                .doc(announce.id)
                                .delete();
                          }
                        }
                      },
                      itemBuilder: (context) {
                        return <PopupMenuItem>[
                          const PopupMenuItem(
                            value: 1,
                            child: Text('Supprimer Annonce',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          )
                        ];
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
      announce.media != null
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: announce.media!,
                  placeholder: (context, url) => SkeletonAnimation(
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                      ),
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ))
          : Container(),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Linkify(
          options: const LinkifyOptions(looseUrl: true),
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw 'Ne peut pas atteindre $link';
            }
          },
          text: "${announce.description}",
          overflow: TextOverflow.ellipsis,
          maxLines: 30,
          style: GoogleFonts.rubik(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          linkStyle: const TextStyle(color: Colors.blue),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0),
        child: Divider(
          color: AppColors.primary,
          thickness: 1,
        ),
      )
    ],
  );
}

class CreateAnnouncement extends StatefulWidget {
  final String eventCode;
  final bool isOnline;
  final String eventName;
  const CreateAnnouncement(this.eventCode, this.isOnline, this.eventName,
      {super.key});
  @override
  _CreateAnnouncementState createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  TextEditingController descriptionController = TextEditingController();
  late String description;
  late File? _image = null;
  final picker = ImagePicker();
  bool uploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faire une annonce'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            uploading = true;
          });
          FirebaseAdd()
              .announce(widget.eventCode, descriptionController.text, _image,
                  widget.isOnline, widget.eventName)
              .then((value) {
            uploading = false;
            Navigator.pop(context);
          });
        },
        backgroundColor: AppColors.tertiary,
        splashColor: Colors.redAccent,
        child: const Icon(Icons.navigate_next, color: Colors.black, size: 35),
      ),
      body: !uploading
          ? SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? SvgPicture.asset(
                            'assets/announce.svg',
                            height: 300,
                          )
                        : Container(),
                    const SizedBox(height: 30),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                          hintText: "Quelle annonce voulez-vous faire?",
                          fillColor: Colors.purple,
                          hintStyle: GoogleFonts.rubik(
                              color: Colors.purple[200],
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10)),
                      style: GoogleFonts.rubik(
                          fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 20),
                    _image == null
                        ? Center(
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.secondary,
                                  ),
                                  onPressed: () async {
                                    final pickedFile = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    setState(() {
                                      _image = File(pickedFile!.path);
                                    });
                                  },
                                  iconSize: 35,
                                  splashColor: AppColors.tertiary,
                                ),
                                const Text("Ajouter une Image",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : Container(
                            child: Center(
                                child: Column(
                            children: [
                              Card(
                                elevation: 8,
                                child: Image.file(_image!,
                                    width: MediaQuery.of(context).size.width *
                                        0.75),
                              ),
                              const SizedBox(height: 20),
                              IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: AppColors.secondary,
                                ),
                                onPressed: () async {
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  setState(() {
                                    _image = File(pickedFile!.path);
                                  });
                                },
                                iconSize: 35,
                                splashColor: AppColors.tertiary,
                              ),
                              const Text("Changer l'image",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ))),
                  ],
                ),
              ),
            ))
          : Center(
              child: SpinKitDoubleBounce(
              color: AppColors.secondary,
              size: 40,
            )),
    );
  }
}
