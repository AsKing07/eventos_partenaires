// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventos_partenaires/methods/getUserId.dart';
import '../globals.dart' as globals;
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:random_string/random_string.dart';

class FirebaseAdd {
  addUser(
      String name, String email, String phoneNumber, String uid, bool isBenin) {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'uid': uid,
      'isBenin': isBenin
    });
  }

  addEvent(
    String eventName,
    String eventCode,
    String eventDescription,
    String eventAddress,
    int maxAttendee,
    File _image,
    DateTime dateTime,
    String? eventLocation,
    String hostName,
    String hostEmail,
    String hostPhone,
    String eventCategory,
    bool isOnline,
    bool isPaid,
    bool isProtected,
    double ticketPrice,
    String? partner,
    String number,
    String? amountEarn,
    String? amountPaid,
  ) async {
    String uid = await getCurrentUid();
    String _uploadedFileURL;
    String fileName = "Banners/$eventCode";
    globals.eventAddLoading = true;

    var _random = Random();
    int i = _random.nextInt(3);

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    final UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    print(taskSnapshot);
    _uploadedFileURL = await firebaseStorageRef.getDownloadURL();

    List<String> eventNameArr = [];

    for (int j = 1; j <= eventName.length; j++) {
      eventNameArr.add(eventName.substring(0, j).toLowerCase());
    }

    if (partner != null) {
      FirebaseFirestore.instance
          .collection('partners')
          .doc(partner)
          .collection('eventsPartnered')
          .doc(eventCode)
          .set({
        'eventCode': eventCode,
        'isOnline': isOnline,
      });
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('eventsHosted')
        .doc(eventCode)
        .set({
      'eventCode': eventCode,
      'isTeam': false,
    });

    if (!isOnline) {
      await FirebaseFirestore.instance.collection('events').doc(eventCode).set({
        'eventCode': eventCode,
        'eventName': eventName,
        'eventDescription': eventDescription,
        'eventAddress': eventAddress,
        'maxAttendee': maxAttendee,
        'eventDateTime': dateTime,
        'eventBanner': _uploadedFileURL,
        'eventNameArr': eventNameArr,
        'joined': 0,
        'scanDone': 0,
        'position': eventLocation,
        'eventLive': true,
        'isPaid': isPaid,
        'isProtected': isProtected,
        'isOnline': isOnline,
        'partner': partner,
        'hostName': hostName,
        'hostEmail': hostEmail,
        'hostPhoneNumber': hostPhone,
        'amountEarned': amountEarn,
        'amount_to_be_paid': amountPaid,
        'ticketPrice': ticketPrice,
        'eventCategory': eventCategory,
        'helper': i,
        'payment_detail': number,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('OnlineEvents')
          .doc(eventCode)
          .set({
        'eventCode': eventCode,
        'eventName': eventName,
        'eventDescription': eventDescription,
        'maxAttendee': maxAttendee,
        'eventDateTime': dateTime,
        'eventBanner': _uploadedFileURL,
        'eventNameArr': eventNameArr,
        'joined': 0,
        'scanDone': 0,
        'eventLive': true,
        'isPaid': isPaid,
        'isProtected': isProtected,
        'isOnline': isOnline,
        'partner': partner,
        'hostName': hostName,
        'hostEmail': hostEmail,
        'hostPhoneNumber': hostPhone,
        'amountEarned': amountEarn,
        'amount_to_be_paid': amountPaid,
        'ticketPrice': ticketPrice,
        'eventCategory': eventCategory,
        'helper': i,
        'payment_detail': number,
      });
    }
  }

  Future<bool> editEvent({
    required String eventName,
    required String eventCode,
    String? eventDescription,
    required String eventAddress,
    required int maxAttendee,
    required DateTime dateTime,
    required String? eventLocation,
    required String hostName,
    required String hostEmail,
    required String hostPhone,
    required String eventCategory,
    required bool isOnline,
    required bool isPaid,
    required double ticketPrice,
    String? upi,
  }) async {
    bool status = true;
    List<String> eventNameArr = [];

    for (int j = 1; j <= eventName.length; j++) {
      eventNameArr.add(eventName.substring(0, j).toLowerCase());
    }

    if (!isOnline) {
      await FirebaseFirestore.instance.collection('events').doc(eventCode).set({
        'eventName': eventName,
        'eventDescription': eventDescription,
        'eventAddress': eventAddress,
        'maxAttendee': maxAttendee,
        'eventDateTime': dateTime,
        'eventNameArr': eventNameArr,
        'position': eventLocation,
        'hostName': hostName,
        'hostEmail': hostEmail,
        'hostPhoneNumber': hostPhone,
        'ticketPrice': ticketPrice,
        'eventCategory': eventCategory,
        'payment_detail': upi,
        'amountEarned': maxAttendee * ticketPrice,
        'amount_to_be_paid': (maxAttendee * ticketPrice) * 92 / 100
      }, SetOptions(merge: true)).then((value) {
        status = true;
        print('ok1');
      });
    } else {
      await FirebaseFirestore.instance
          .collection('OnlineEvents')
          .doc(eventCode)
          .set({
        'eventName': eventName,
        'eventDescription': eventDescription,
        'eventAddress': eventAddress,
        'maxAttendee': maxAttendee,
        'eventDateTime': dateTime,
        'eventNameArr': eventNameArr,
        'hostName': hostName,
        'hostEmail': hostEmail,
        'hostPhoneNumber': hostPhone,
        'ticketPrice': ticketPrice,
        'eventCategory': eventCategory,
        'payment_detail': upi,
        'amountEarned': maxAttendee * ticketPrice,
        'amount_to_be_paid': (maxAttendee * ticketPrice) * 92 / 100
      }, SetOptions(merge: true)).then((value) {
        status = true;
        print('ok');
      });
    }
    return status;
  }

  Future<bool> announce(String eventCode, String description, File? image,
      bool isOnline, String eventName) async {
    String? _uploadedFileURL;
    String id = randomAlphaNumeric(8);

    if (image != null) {
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("$eventCode/${randomAlphaNumeric(8)}");
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      print(taskSnapshot);

      _uploadedFileURL = await firebaseStorageRef.getDownloadURL();
    }

    DocumentReference announcementRef =
        FirebaseFirestore.instance.collection('Announcements').doc(id);
    DocumentReference eventAnnouncementRef;

    Map<String, dynamic> announcementData = {
      'description': description,
      'eventName': eventName,
      'media': _uploadedFileURL,
      'token': eventCode,
      'timestamp': FieldValue.serverTimestamp(),
      'id': id,
    };

    await announcementRef.set(announcementData);

    if (isOnline) {
      eventAnnouncementRef = FirebaseFirestore.instance
          .collection("OnlineEvents")
          .doc(eventCode)
          .collection('Announcements')
          .doc(id);
    } else {
      eventAnnouncementRef = FirebaseFirestore.instance
          .collection("events")
          .doc(eventCode)
          .collection('Announcements')
          .doc(id);
    }

    await eventAnnouncementRef.set(announcementData);

    return true;
  }
}
