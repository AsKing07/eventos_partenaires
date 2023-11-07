import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eventos_partenaires/methods/firebaseAdd.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'dart:async';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditPage extends StatefulWidget {
  final DocumentSnapshot post;
  final Function rebuild;
  EditPage(this.post, this.rebuild);
  @override
  MapScreenState createState() => MapScreenState();
  static const kInitialPosition = maps.LatLng(2.4144192, 6.3752311);
}

class MapScreenState extends State<EditPage>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Completer<maps.GoogleMapController> _controller = Completer();
  bool _autoValidate = false;
  String selectedCategory = "Concert/Performance";
  // GeoFlutterFire geo = GeoFlutterFire();
  // late PickResult mainResult;
  // GeoFirePoint? firePoint;
  String countryValue = "", stateValue = "", cityValue = "";
  String localisation = '';
  String city = "";

  TextEditingController eventAddController = TextEditingController();
  TextEditingController ticketPriceController = TextEditingController();
  TextEditingController paymentDetailController = TextEditingController();
  List<DropdownMenuItem> categoryList = [
    DropdownMenuItem(
      value: 'Appearance/Singing',
      child: Text(
        'Apparition/Chant',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Attaraction',
      child: Text(
        'Rencontre',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Camp, Trip or Retreat',
      child: Text(
        'Camp, voyage ou retraite',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Class, Training, or Workshop',
      child: Text(
        'Cours, formation ou atelier',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Concert/Performance',
      child: Text(
        'Concert/Performance',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Conference',
      child: Text(
        'Conference',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Convention',
      child: Text(
        'Conférence',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Dinner or Gala',
      child: Text(
        'Dinner ou Gala',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Festival or Fair',
      child: Text(
        'Festival ou foire',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Game or Competition',
      child: Text(
        'Jeu ou Competition',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Meeting/Networking event',
      child: Text(
        'Meeting/Réseautage',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Party/Social Gathering',
      child: Text(
        'Fête/rassemblement social',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
    DropdownMenuItem(
      value: 'Other',
      child: Text(
        'Autres',
        style: GoogleFonts.cabin(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    ),
  ];

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      if (countryValue.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Veuillez sélectionner un pays :( ',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else if (stateValue.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Veuillez sélectionner un département:( ',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else if (cityValue.isEmpty) {
        Fluttertoast.showToast(
            msg: 'Veuillez sélectionner une ville :( ',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else {
        _formKey.currentState!.save();
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = widget.post['isOnline'];
    bool isPaid = widget.post['isPaid'];
    bool isProtected = widget.post['isProtected'];
    DateTime dateTime = widget.post['eventDateTime'].toDate();
    final hostNameController =
        TextEditingController(text: widget.post['hostName']);
    final hostEmailController =
        TextEditingController(text: widget.post['hostEmail']);
    final hostPhoneController =
        TextEditingController(text: widget.post['hostPhoneNumber']);
    final nameController =
        TextEditingController(text: widget.post['eventName']);
    final descriptionController =
        TextEditingController(text: widget.post['eventDescription']);
    final maxAttendeeController =
        TextEditingController(text: widget.post['maxAttendee'].toString());
    paymentDetailController =
        TextEditingController(text: widget.post['payment_detail'].toString());
    final dateTimeController = TextEditingController(
        text: DateFormat('dd-MM-yyyy  hh:mm a').format(dateTime));

    if (!isOnline) {
      eventAddController =
          TextEditingController(text: widget.post['eventAddress']);
    }

    !isOnline
        ? localisation = widget.post['position']

        // firePoint = geo.point(
        //     latitude: widget.post['position']['geopoint'].latitude,
        //     longitude: widget.post['position']['geopoint'].longitude)
        : {};
    isPaid
        ? ticketPriceController =
            TextEditingController(text: widget.post['ticketPrice'].toString())
        : ticketPriceController = TextEditingController(text: '0');
    selectedCategory = widget.post["eventCategory"];
    void updateLocation(String? country, String? state, String? city) {
      setState(() {
        localisation = '$country,  $state,  $city';
      });
      print(localisation);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Editer Evenement"),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              Form(
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      color: const Color(0xffFFFFFF),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Editer information',
                                          style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _status ? _getEditIcon() : Container(),
                                      ],
                                    )
                                  ],
                                )),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 10.0),
                                child: Text(
                                  '*Pour toute modification supplémentaire, contactez votre assistant personnel',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red),
                                )),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Text(
                                  'Nom de l\'évènement:',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        controller: nameController,
                                        onChanged: (s) {
                                          print(nameController.text);
                                        },
                                        validator: (value) => value!.length < 2
                                            ? '*doit être de 2 caractères minimum'
                                            : null,
                                        decoration: const InputDecoration(
                                          hintText: 'Nom de l\'évènement',
                                        ),
                                        enabled: !_status,
                                        autofocus: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        maxLines: 3,
                                        validator: (value) => value!.length < 2
                                            ? '*2 caractères minimum'
                                            : null,
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                            hintText: 'Description'),
                                        enabled: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 12.0),
                              child: DropdownButtonFormField(
                                items: categoryList,
                                validator: (value) => selectedCategory == null
                                    ? 'Selectionner une categorie'
                                    : null,
                                value: selectedCategory,
                                decoration: InputDecoration(
                                  enabled: !_status,
                                  labelStyle: GoogleFonts.cabin(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.black),
                                  labelText: 'Categorie de l\'évenement',
                                ),
                                onChanged: (value) {
                                  selectedCategory = value;
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 30.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Information de l\'Organisateur',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Nom de l\'organisaeur',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        validator: (value) =>
                                            value!.trim().isNotEmpty
                                                ? null
                                                : 'Entrer un nom valide',
                                        controller: hostNameController,
                                        decoration: const InputDecoration(
                                            hintText: 'Nom de l\'organisateur'),
                                        enabled: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: const Text(
                                          'Numéro de téléphone',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: const Text(
                                          'Email',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: TextFormField(
                                          controller: hostPhoneController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              hintText: "Numéro de téléphone"),
                                          enabled: !_status,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: TextFormField(
                                        validator: (value) {
                                          String pattern =
                                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
                                          RegExp regex = RegExp(pattern);
                                          if (!regex.hasMatch(value!)) {
                                            return 'Entrer un Email valide';
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller: hostEmailController,
                                        decoration: const InputDecoration(
                                          hintText:
                                              "Entrer Email de l'organisateur",
                                        ),
                                        enabled: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 30.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Date & Heure',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: GestureDetector(
                                onTap: () async {
                                  final DateTime? picked =
                                      await DatePicker.showDateTimePicker(
                                          locale: LocaleType.fr,
                                          context,
                                          showTitleActions: true,
                                          minTime: DateTime.now(),
                                          maxTime: DateTime.now()
                                              .add(const Duration(days: 365)));
                                  if (picked != null && picked != dateTime) {
                                    dateTime = picked;
                                    dateTimeController.text =
                                        DateFormat('dd-MM-yyyy  hh:mm')
                                            .format(dateTime);
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    enabled: !_status,
                                    controller: dateTimeController,
                                    validator: (value) => null,
                                    decoration: const InputDecoration(
                                      hintText: "Date & Heure de l'évènement",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            !isOnline
                                ? const Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 30.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Adresse',
                                          style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Si vous changer un des trois éléments(Pays, Département, Ville), vous devrez également redéfinir les 2 autres!',
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            !isOnline
                                ? Container(
                                    child: Column(
                                      children: [
                                        SelectState(
                                          // style: TextStyle(color: Colors.red),
                                          onCountryChanged: (value) {
                                            setState(() {
                                              countryValue = value;
                                            });
                                            updateLocation(countryValue,
                                                stateValue, cityValue);
                                          },
                                          onStateChanged: (value) {
                                            setState(() {
                                              stateValue = value;
                                              updateLocation(countryValue,
                                                  stateValue, cityValue);
                                            });
                                          },
                                          onCityChanged: (value) {
                                            setState(() {
                                              cityValue = value;
                                              updateLocation(countryValue,
                                                  stateValue, cityValue);
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            !isOnline
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: TextFormField(
                                      validator: (value) => value!.length < 10
                                          ? '*doit contenir au moins 10 caractères'
                                          : null,
                                      decoration: const InputDecoration(
                                          hintText: 'Addresse'),
                                      controller: eventAddController,
                                      enabled: !_status,
                                    ),
                                  )
                                : Container(),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 30.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Ticket Info',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            isPaid
                                ? const Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Prix du Ticket',
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                : Container(),
                            isPaid
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            validator: (value) => value!
                                                    .trim()
                                                    .isNotEmpty
                                                ? double.parse(value) >= 1000
                                                    ? null
                                                    : 'Enter un montant valide ( >1000 FCFA)'
                                                : 'Enter un montant valide ( >1000FCFA)',
                                            controller: ticketPriceController,
                                            decoration: const InputDecoration(
                                                prefixIcon: Icon(
                                                    FontAwesomeIcons.moneyBill),
                                                hintText: 'Prix Ticket'),
                                            enabled: !_status,
                                          ),
                                        ),
                                      ],
                                    ))
                                : Container(),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Nombre de tickets disponibles',
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        validator: (value) => value!
                                                .trim()
                                                .isNotEmpty
                                            ? int.parse(value) >= 10
                                                ? null
                                                : 'Entrer un nombre valide (>10)'
                                            : 'Entrer un nombre valide (>10)',
                                        controller: maxAttendeeController,
                                        decoration: const InputDecoration(
                                            hintText: 'Nombre de tickets'),
                                        enabled: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Numéro Momo MTN',
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextFormField(
                                        controller: hostPhoneController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Numéro de téléphone de payement MTN Mobile money"),
                                        enabled: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            !_status
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 45.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Container(
                                                child: ElevatedButton(
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  double ticketPrice =
                                                      double.parse(
                                                          ticketPriceController
                                                              .text);
                                                  int ticketCount = int.parse(
                                                      maxAttendeeController
                                                          .text);
                                                  await FirebaseAdd()
                                                      .editEvent(
                                                    eventName:
                                                        nameController.text,
                                                    eventCode: widget
                                                        .post['eventCode'],
                                                    eventDescription:
                                                        descriptionController
                                                            .text,
                                                    eventAddress:
                                                        eventAddController.text,
                                                    maxAttendee: ticketCount,
                                                    dateTime: dateTime,
                                                    eventLocation: localisation,
                                                    hostName:
                                                        hostNameController.text,
                                                    hostEmail:
                                                        hostEmailController
                                                            .text,
                                                    hostPhone:
                                                        hostPhoneController
                                                            .text,
                                                    eventCategory:
                                                        selectedCategory,
                                                    isOnline: isOnline,
                                                    isPaid: isPaid,
                                                    ticketPrice: ticketPrice,
                                                    upi: paymentDetailController
                                                        .text,
                                                  )
                                                      .then((val) {
                                                    print('up');
                                                    if (val) {
                                                      setState(() {
                                                        _status = true;
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FocusNode());
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              'Événement édité avec succès',
                                                          backgroundColor:
                                                              Colors.green,
                                                          textColor:
                                                              Colors.white,
                                                          gravity:
                                                              ToastGravity.TOP,
                                                        );
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        widget.rebuild();
                                                      });
                                                    } else {
                                                      print("erreur: $val");
                                                    }
                                                  });
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.green),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text("Enregistrer",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            )),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Container(
                                                child: ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  _status = true;
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          FocusNode());
                                                });
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.red),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text("Annuler",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 20.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
