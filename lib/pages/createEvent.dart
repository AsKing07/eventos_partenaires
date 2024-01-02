// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/methods/firebaseAdd.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:random_string/random_string.dart';
import 'package:eventos_partenaires/Widgets/clipper.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/config/size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CreateEvent extends StatefulWidget {
  final String uid;
  CreateEvent(this.uid);
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  GeoFlutterFire geo = GeoFlutterFire();
  late String? eventName, eventDescription, eventCode;
  String eventAddress = "";
  late String hostName, hostEmail, hostPhoneNumber;
  String _phone = "";
  late String isoCode;
  late int maxAttendees;
  String countryValue = "", stateValue = "", cityValue = "";
  String localisation = '';

  bool imageDone = false;
  // PickResult? mainResult;
  // late GeoFirePoint? myLocation = null;
  late DateTime? dateTime = null;
  Completer<maps.GoogleMapController> _controller = Completer();
  final hostNameController = TextEditingController();
  final hostEmailController = TextEditingController();
  final hostPhoneController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final eventAddController = TextEditingController();
  final maxAttendeeController = TextEditingController();
  final dateTimeController = TextEditingController();
  String selectedCategory = "Concert/Performance";
  bool isOnline = false;

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
        'Convention',
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

  void _inputChange(
      String number, PhoneNumber internationlizedPhoneNumber, String isoCode) {
    setState(() {
      isoCode = isoCode;
      _phone = number;
      if (internationlizedPhoneNumber.completeNumber != null) {
        hostPhoneNumber = internationlizedPhoneNumber.completeNumber!;
      }
    });
  }

  onEventSelect(int x) {
    if (x == 0) {
      setState(() {
        isOnline = false;
      });
    } else {
      setState(() {
        isOnline = true;
        // localisation = "";
        // eventAddress = "";
      });
    }

    print(isOnline);
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      if (!isOnline) {
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
        }
      }
      if (hostPhoneNumber == null) {
        Fluttertoast.showToast(
            msg: 'Numéro de téléphone non valide :( ',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else if (dateTime == null) {
        Fluttertoast.showToast(
            msg: 'Date et Heure non valides ',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else if ((localisation.isEmpty || eventAddController.text.isEmpty) &&
          !isOnline) {
        print(localisation);
        print(eventAddController.text);
        Fluttertoast.showToast(
            msg: 'Définissez la localisation de l\'évènement',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else {
        _formKey.currentState!.save();
        eventCode = randomAlphaNumeric(6);
        print(eventCode);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PosterSelect(
            eventName: nameController.text,
            eventDescription: descriptionController.text,
            eventCategory: selectedCategory,
            hostName: hostNameController.text,
            hostEmail: hostEmailController.text,
            hostPhoneNumber: hostPhoneNumber,
            isOnline: isOnline,
            location: localisation,
            eventAddress: eventAddController.text,
            eventDateTime: dateTime,
            eventCode: eventCode,
          );
        }));
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void updateLocation(String? country, String? state, String? city) {
    setState(() {
      localisation = '$country,  $state,  $city';
    });
    print(localisation);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        locale: LocaleType.fr,
        minTime: DateTime.now(),
        maxTime: DateTime.now().add(new Duration(days: 365)));
    if (picked != null && picked != dateTime) {
      setState(() {
        dateTime = picked;
        dateTimeController.text =
            DateFormat('dd-MM-yyyy  hh:mm').format(dateTime!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Creer un évènement',
            style:
                GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 25)),
        centerTitle: true,
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: width / 20),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Infos Basics',
                    style: GoogleFonts.cabin(
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: const Color(0xff1E0A3C),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 12),
                child: Text(
                    'Nommez votre événement et dites aux participants pourquoi ils devraient venir. Ajoutez des détails qui mettent en valeur ce qui le rend unique.',
                    style: GoogleFonts.mavenPro(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: const Color(0xff39364f),
                    )),
              ),
              Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    EventCreateTextField(
                      maxLines: 1,
                      number: false,
                      width: 0.5,
                      radius: 5,
                      controller: nameController,
                      validator: (value) => value!.length < 2
                          ? '*doit être de 2 caractères minimum'
                          : null,
                      hint: "Nom",
                      icon: Icon(
                        FontAwesomeIcons.font,
                        color: AppColors.secondary,
                      ),
                      onSaved: (input) {
                        eventName = input!;
                      },
                    ),
                    const SizedBox(height: 20),
                    EventCreateTextField(
                      maxLines: 5,
                      number: false,
                      width: 0.5,
                      radius: 5,
                      controller: descriptionController,
                      validator: (value) =>
                          value!.length < 2 ? '*2 caractères minimum' : null,
                      hint: "Description",
                      icon: Icon(
                        Icons.border_color,
                        color: AppColors.secondary,
                      ),
                      onSaved: (input) {
                        eventDescription = input!;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      items: categoryList,
                      validator: (value) => selectedCategory == null
                          ? 'Selectionner une categorie'
                          : null,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.cabin(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.primary),
                        labelText: 'Categorie',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Infos de l\'organisateur',
                            style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: const Color(0xff1E0A3C),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 12),
                      child: Text(
                          'Aidez les invités en fournissant des informations sur l\'hôte de l\'événement, ces informations seront affichées sur la page de l\'événement.',
                          style: GoogleFonts.mavenPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color(0xff39364f),
                          )),
                    ),
                    EventCreateTextField(
                      maxLines: 1,
                      number: false,
                      width: 0.5,
                      radius: 5,
                      controller: hostNameController,
                      validator: (value) => value!.trim().isNotEmpty
                          ? null
                          : 'Entrez un nom valide',
                      hint: "Nom de l'organisateur",
                      icon: Icon(
                        FontAwesomeIcons.font,
                        color: AppColors.secondary,
                      ),
                      onSaved: (input) {
                        hostName = input!;
                      },
                    ),
                    const SizedBox(height: 20),
                    EventCreateTextField(
                      maxLines: 1,
                      number: false,
                      width: 0.5,
                      radius: 5,
                      controller: hostEmailController,
                      validator: (value) {
                        // RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                        RegExp regex = RegExp(
                            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                        if (!regex.hasMatch(value!)) {
                          return 'Entrez un email valide';
                        } else {
                          return null;
                        }
                      },
                      hint: "Email",
                      icon: Icon(
                        FontAwesomeIcons.at,
                        color: AppColors.secondary,
                      ),
                      onSaved: (input) {
                        hostEmail = input!;
                      },
                    ),
                    const SizedBox(height: 20),
                    IntlPhoneField(
                      focusNode: FocusNode(),
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      languageCode: "fr",
                      onChanged: (number) {
                        _inputChange(number.number ?? '', number,
                            number.countryISOCode!);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Localisation',
                            style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: const Color(0xff1E0A3C),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 12),
                      child: Text(
                          'Aidez les gens de la région à découvrir votre événement et indiquez aux participants où se présenter.',
                          style: GoogleFonts.mavenPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color(0xff39364f),
                          )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            onEventSelect(0);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1.5, color: AppColors.primary),
                              color: isOnline
                                  ? Colors.white
                                  : AppColors.tertiary.withOpacity(1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                  child: Text(
                                'En Présentiel',
                                style: GoogleFonts.cabin(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.primary),
                              )),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            onEventSelect(1);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1.5, color: AppColors.primary),
                              color: !isOnline
                                  ? Colors.white
                                  : AppColors.tertiary.withOpacity(1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                  child: Text('En ligne',
                                      style: GoogleFonts.cabin(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          color: AppColors.primary))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                                    updateLocation(
                                        countryValue, stateValue, cityValue);
                                  },
                                  onStateChanged: (value) {
                                    setState(() {
                                      stateValue = value;
                                      updateLocation(
                                          countryValue, stateValue, cityValue);
                                    });
                                  },
                                  onCityChanged: (value) {
                                    setState(() {
                                      cityValue = value;
                                      updateLocation(
                                          countryValue, stateValue, cityValue);
                                    });
                                  },
                                )
                              ],
                            ),
                          )
                        : Text(
                            'Aucun emplacement n\'est requis dans les événements en ligne, vous pouvez partager le lien de diffusion/rejoindre en utilisant la fonction d\'annonce',
                            style: GoogleFonts.mavenPro(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: const Color(0xff39364f),
                            )),
                    localisation.isNotEmpty
                        ? const SizedBox(height: 20)
                        : Container(),
                    localisation.isNotEmpty
                        ? EventCreateTextField(
                            maxLines: 1,
                            number: false,
                            width: 0.5,
                            radius: 5,
                            controller: eventAddController,
                            validator: (value) => value!.length < 10
                                ? '*minimum 10 caractères'
                                : null,
                            hint: "Adresse précise de l'évènement",
                            icon: Icon(
                              Icons.near_me,
                              color: AppColors.secondary,
                            ),
                            onSaved: (input) {
                              eventAddress = input!;
                            },
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Date & Heure',
                            style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              color: const Color(0xff1E0A3C),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 12),
                      child: Text(
                          'Informez les participants du début de votre événement afin qu’ils puissent planifier leur participation.',
                          style: GoogleFonts.mavenPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color(0xff39364f),
                          )),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                          child: EventCreateTextField(
                        maxLines: 1,
                        number: false,
                        width: 0.5,
                        radius: 5,
                        controller: dateTimeController,
                        validator: (value) => null,
                        hint: "Heure & Date",
                        icon: Icon(
                          FontAwesomeIcons.calendar,
                          color: AppColors.secondary,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              Align(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _validateInputs();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continuer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            FontAwesomeIcons.arrowRight,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class PosterSelect extends StatefulWidget {
  final String? eventName;
  final String? eventDescription;
  final String? eventCategory;
  final String? hostName;
  final String? hostEmail;
  final String? hostPhoneNumber;
  final String? eventAddress;
  final String? eventCode;
  final bool? isOnline;
  final DateTime? eventDateTime;
  final String? location;
  const PosterSelect(
      {super.key,
      this.eventName,
      this.eventDescription,
      this.eventCategory,
      this.hostName,
      this.hostEmail,
      this.hostPhoneNumber,
      this.isOnline,
      this.location,
      this.eventAddress,
      this.eventDateTime,
      this.eventCode});
  @override
  _PosterSelectState createState() => _PosterSelectState();
}

class _PosterSelectState extends State<PosterSelect> {
  @override
  void initState() {
    super.initState();
    print(widget.eventCategory);
    print(widget.eventDateTime);
    print(widget.eventDescription);
    print(widget.eventName);
    print(widget.hostEmail);
    print(widget.hostName);
    print(widget.hostPhoneNumber);
    print(widget.isOnline);
    print(widget.eventAddress);
    print(widget.location);
  }

  late CroppedFile? _image =
      null; // Conservez _image comme un objet de type CroppedFile
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      _image = await ImageCropper()
          .cropImage(sourcePath: pickedFile.path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Redimensionner votre image',
            toolbarColor: AppColors.tertiary,
            toolbarWidgetColor: AppColors.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Poster',
            style:
                GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 25)),
        centerTitle: true,
      ),
      floatingActionButton: _image != null
          ? FloatingActionButton(
              backgroundColor: AppColors.secondary,
              splashColor: AppColors.tertiary,
              onPressed: () {
                if (_image == null) {
                  Fluttertoast.showToast(
                      msg: 'Selectionner une photo',
                      backgroundColor: Colors.red,
                      fontSize: 18,
                      textColor: Colors.white,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TicketInfo(
                        eventName: widget.eventName,
                        eventDescription: widget.eventDescription,
                        eventCategory: widget.eventCategory,
                        eventAddress: widget.eventAddress,
                        location: widget.location,
                        hostName: widget.hostName,
                        hostEmail: widget.hostEmail,
                        hostPhoneNumber: widget.hostPhoneNumber,
                        eventDateTime: widget.eventDateTime,
                        isOnline: widget.isOnline,
                        image: _image,
                        eventCode: widget.eventCode);
                  }));
                }
              },
              child: const Icon(Icons.navigate_next,
                  color: Colors.white, size: 30),
            )
          : Container(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
              left: width / 20, right: width / 20, bottom: height / 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text('Image',
                      style: GoogleFonts.cabin(
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                        color: const Color(0xff1E0A3C),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Text(
                      'C\'est la première image que les gens verront en haut de votre annonce. Une affiche verticale est recommandée.',
                      style: GoogleFonts.mavenPro(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: const Color(0xff39364f),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                _image == null
                    ? InkWell(
                        onTap: () => getImage(),
                        child: Container(
                          color: Colors.purple[50]!.withOpacity(0.7),
                          height: height / 2,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      FontAwesomeIcons.image,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Selectionner un poster image depuis votre gallerie.',
                                      style: GoogleFonts.cabin(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 26,
                                        color: const Color(0xff1E0A3C),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Image verticale recommandée.',
                                      style: GoogleFonts.mavenPro(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                          color: Colors.purple[200]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: InkWell(
                          child: _image != null
                              ? Image.file(
                                  File(_image!
                                      .path), // Conversion du CroppedFile en File.
                                  height: height / 1.5,
                                )
                              : const Placeholder(), // Vous pouvez utiliser n'importe quel widget de substitution lorsque _image est nul.
                          onTap: () => getImage(),
                        ),
                      )
              ]),
        ),
      ),
    );
  }
}

class TicketInfo extends StatefulWidget {
  final String? eventName;
  final String? eventDescription;
  final String? eventCategory;
  final String? hostName;
  final String? hostEmail;
  final String? hostPhoneNumber;
  final String? eventAddress;
  final String? eventCode;
  final bool? isOnline;
  final DateTime? eventDateTime;
  final String? location;
  final CroppedFile? image;
  const TicketInfo(
      {super.key,
      this.eventName,
      this.eventDescription,
      this.eventCategory,
      this.hostName,
      this.hostEmail,
      this.hostPhoneNumber,
      this.isOnline,
      this.location,
      this.eventAddress,
      this.eventDateTime,
      this.eventCode,
      this.image});
  @override
  _TicketInfoState createState() => _TicketInfoState();
}

class _TicketInfoState extends State<TicketInfo> {
  bool isProtected = false;
  bool isPaid = true;
  double ticketPrice = 0;
  int ticketCount = 0;
  TextEditingController ticketPriceController = TextEditingController();
  TextEditingController ticketCountController = TextEditingController();
  TextEditingController passcodeController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  onPaidSelect(String x) {
    if (x == 'yes') {
      setState(() {
        isPaid = true;
      });
    } else {
      setState(() {
        isPaid = false;
        ticketPriceController.clear();
        ticketPrice = 0;
      });
    }
    print(isPaid);
  }

  onProtectSelect(String x) {
    if (x == 'yes') {
      setState(() {
        isProtected = true;
      });
    } else {
      setState(() {
        isProtected = false;
      });
    }
    print(isProtected);
  }

  void validateInputs() async {
    String pattern = r'^\d{1,8}$';
    RegExp regex = new RegExp(pattern);
    if (ticketCount <= 10) {
      Fluttertoast.showToast(
          msg: 'Le nombre de ticket doit être supérieur à 10 ',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);
    } else if (ticketPrice <= 1000 && isPaid == true) {
      Fluttertoast.showToast(
          msg: 'Le prix du billet doit être supérieur à 1000 FCFA ',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);
    } else if (!regex.hasMatch(numberController.text) && isPaid == true) {
      Fluttertoast.showToast(
          msg: 'Entrez un numéro de payement valide',
          backgroundColor: Colors.red,
          fontSize: 18,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP);
    } else if (passcodeController.text.trim().isNotEmpty &&
        passcodeController.text != null &&
        passcodeController.text != '') {
      final x = await FirebaseFirestore.instance
          .collection('partners')
          .doc(passcodeController.text)
          .get();
      if (!x.exists) {
        Fluttertoast.showToast(
            msg: 'Code partenaire non valide ajouté',
            backgroundColor: Colors.red,
            fontSize: 18,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP);
      } else {
        File? imageFile;

        if (widget.image?.path != null) {
          imageFile = File(widget.image!.path);
        }
        await FirebaseAdd().addEvent(
          widget.eventName!,
          widget.eventCode!,
          widget.eventDescription!,
          widget.eventAddress!,
          ticketCount,
          imageFile!,
          widget.eventDateTime!,
          widget.location!,
          widget.hostName!,
          widget.hostEmail!,
          widget.hostPhoneNumber!,
          widget.eventCategory!,
          widget.isOnline!,
          isPaid,
          isProtected,
          ticketPrice,
          passcodeController.text,
          numberController.text,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CongoScreen(widget.eventName!, widget.eventCode!,
              widget.eventAddress!, widget.image!, widget.eventDateTime!);
        }));
      }
    } else {
      File? imageFile;

      if (widget.image?.path != null) {
        imageFile = File(widget.image!.path);
      }

      await FirebaseAdd().addEvent(
        widget.eventName!,
        widget.eventCode!,
        widget.eventDescription!,
        widget.eventAddress!,
        ticketCount,
        imageFile!,
        widget.eventDateTime!,
        widget.location,
        widget.hostName!,
        widget.hostEmail!,
        widget.hostPhoneNumber!,
        widget.eventCategory!,
        widget.isOnline!,
        isPaid,
        isProtected,
        ticketPrice,
        null,
        numberController.text,
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CongoScreen(widget.eventName!, widget.eventCode!,
            widget.eventAddress!, widget.image!, widget.eventDateTime!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    // double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Infos Ticket',
            style:
                GoogleFonts.cabin(fontWeight: FontWeight.w600, fontSize: 25)),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: width / 20),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text('Info Ticket',
                  style: GoogleFonts.cabin(
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                    color: const Color(0xff1E0A3C),
                  )),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    onPaidSelect('yes');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1.5, color: AppColors.primary),
                      color: !isPaid
                          ? Colors.white
                          : AppColors.tertiary.withOpacity(1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: Text(
                        'Payant',
                        style: GoogleFonts.cabin(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.primary),
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    onPaidSelect('');
                  },
                  child: Container(
                    width: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1.5, color: AppColors.primary),
                      color: isPaid
                          ? Colors.white
                          : AppColors.tertiary.withOpacity(1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: Text('Gratuit',
                              style: GoogleFonts.cabin(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: AppColors.primary))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            isPaid
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150,
                        child: TextField(
                          controller: ticketPriceController,
                          style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800, fontSize: 16),
                          onChanged: (val) {
                            setState(() {
                              if (val.trim().isEmpty) {
                                ticketPrice = 0;
                              } else {
                                ticketPrice = double.parse(val);
                              }
                            });
                          },
                          decoration: InputDecoration(
                              labelText: 'Prix Ticket',
                              labelStyle: GoogleFonts.cabin(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: AppColors.secondary),
                              alignLabelWithHint: true,
                              prefixIcon: Icon(FontAwesomeIcons.moneyBill,
                                  color: AppColors.primary)),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Expanded(
                          child: Icon(
                        FontAwesomeIcons.times,
                        size: 30,
                      )),
                      Container(
                        width: 150,
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              if (val.trim().isEmpty) {
                                ticketCount = 0;
                              } else {
                                ticketCount = int.parse(val);
                              }
                            });
                          },
                          controller: ticketCountController,
                          style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Nombre de tickets',
                            alignLabelWithHint: true,
                            labelStyle: GoogleFonts.cabin(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppColors.secondary),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  )
                : EventCreateTextField(
                    maxLines: 1,
                    number: true,
                    width: 0.5,
                    radius: 5,
                    controller: ticketCountController,
                    hint: "Nombre de tickets",
                    icon: Icon(
                      FontAwesomeIcons.calculator,
                      color: AppColors.secondary,
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val!.trim().isEmpty) {
                          ticketCount = 0;
                        } else {
                          ticketCount = int.parse(val);
                        }
                      });
                    },
                  ),
            isPaid ? const SizedBox(height: 10) : Container(),
            isPaid
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Text('Revenu brut:',
                            style: GoogleFonts.cabin(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: const Color(0xff1E0A3C),
                            )),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(FontAwesomeIcons.moneyBill,
                                  size: 25, color: Color(0xff1E0A3C)),
                              const SizedBox(
                                width: 5,
                              ),
                              Text('${ticketPrice * ticketCount}',
                                  style: GoogleFonts.cabin(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: AppColors.primary,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            isPaid
                ? Text('(Prix ticket * Nombre ticket)',
                    style: GoogleFonts.mavenPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: const Color(0xff39364f),
                    ))
                : Container(),
            isPaid
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Text('Revenu Estimé:',
                            style: GoogleFonts.cabin(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xff1E0A3C))),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(FontAwesomeIcons.moneyBill,
                                  size: 25, color: Color(0xff1E0A3C)),
                              const SizedBox(
                                width: 5,
                              ),
                              Text('${(ticketPrice * ticketCount) * 98 / 100}',
                                  style: GoogleFonts.cabin(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 26,
                                    color: AppColors.primary,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            isPaid
                ? Text('(Gain brut - Frais Equipe EventOs 2%)',
                    style: GoogleFonts.mavenPro(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: const Color(0xff39364f),
                    ))
                : Container(),
            isPaid ? const SizedBox(height: 5) : Container(),
            isPaid
                ? Text('*Il s\'agit du montant en FCFA que vous recevrez.',
                    style: GoogleFonts.cabin(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.red,
                    ))
                : Container(),
            isPaid ? const SizedBox(height: 20) : Container(),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Evènement privé?',
                    style: GoogleFonts.cabin(
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: const Color(0xff1E0A3C),
                    )),
                Switch(
                  value: isProtected,
                  activeColor: AppColors.secondary,
                  onChanged: (value) {
                    setState(() {
                      isProtected = value;
                    });
                  },
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 12),
                child: isProtected
                    ? Text(
                        'Seules les personnes possédant un code peuvent acheter ou échanger des pass pour cet événement.Le code vous sera fournit ultérieurement! ',
                        softWrap: true,
                        style: GoogleFonts.mavenPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: const Color(0xff39364f)))
                    : Text(
                        'Tout le monde peut acheter des pass pour cet événement',
                        style: GoogleFonts.mavenPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: const Color(0xff39364f)))),
            isPaid ? const SizedBox(height: 10) : Container(),
            isPaid ? const Divider(thickness: 1) : Container(),
            isPaid ? const SizedBox(height: 8) : Container(),
            isPaid
                ? Text('Code partenaire',
                    style: GoogleFonts.cabin(
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: const Color(0xff1E0A3C),
                    ))
                : Container(),
            isPaid
                ? Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 12),
                    child: Text(
                        'Si vous êtes référé par l\'un de nos Partenaires, merci de mentionner son code.',
                        style: GoogleFonts.mavenPro(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: const Color(0xff39364f),
                        )),
                  )
                : Container(),
            isPaid
                ? EventCreateTextField(
                    maxLines: 1,
                    number: false,
                    width: 0.5,
                    radius: 5,
                    controller: passcodeController,
                    hint: "Code ici",
                    icon: Icon(
                      FontAwesomeIcons.keyboard,
                      color: AppColors.secondary,
                    ),
                    onChanged: (val) {},
                  )
                : Container(),
            isPaid ? const SizedBox(height: 10) : Container(),
            isPaid ? const Divider(thickness: 1) : Container(),
            isPaid ? const SizedBox(height: 8) : Container(),
            isPaid
                ? Text('Détails de payement',
                    style: GoogleFonts.cabin(
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: const Color(0xff1E0A3C),
                    ))
                : Container(),
            isPaid
                ? Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 12),
                    child: Text(
                        'Entrez votre numéro momo pour recevoir le paiement. Le paiement sera transféré sur ce numéro dès que possible! Pour tout autre mode de paiement, contactez votre assistant personnel qui vous sera attribué après la création de l\'événement',
                        style: GoogleFonts.mavenPro(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: const Color(0xff39364f),
                        )),
                  )
                : Container(),
            isPaid
                ? EventCreateTextField(
                    maxLines: 1,
                    number: false,
                    width: 0.5,
                    radius: 5,
                    controller: numberController,
                    hint: "Numéro Momo",
                    icon: Icon(
                      FontAwesomeIcons.keyboard,
                      color: AppColors.secondary,
                    ),
                    onChanged: (val) {},
                  )
                : Container(),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            Align(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    validateInputs();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(10.0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Créer un événement',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        FontAwesomeIcons.arrowRight,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}

class CongoScreen extends StatefulWidget {
  final String eventCode;
  final String eventName;
  final String eventAddress;
  final DateTime dateTime;
  final CroppedFile image;
  CongoScreen(
    this.eventName,
    this.eventCode,
    this.eventAddress,
    this.image,
    this.dateTime,
  );
  @override
  _CongoScreenState createState() => _CongoScreenState();
}

class _CongoScreenState extends State<CongoScreen> {
  late ConfettiController _controllerCenter;
  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  Widget build(BuildContext context) {
    double height = SizeConfig.getHeight(context);
    double width = SizeConfig.getWidth(context);
    _controllerCenter.play();
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton.extended(
            label: const Text('Terminer'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return HomePage();
              }), ModalRoute.withName('/homepage'));
            },
            icon: const Icon(Icons.play_arrow),
            tooltip: 'continuer',
            backgroundColor: Colors.redAccent,
          ),
        ),
      ),
      body: Container(
        child: Center(
            child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: AppColors.tertiary,
                  height: 100,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: height / 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("Votre évènement est créé",
                          style: GoogleFonts.lora(
                            textStyle: TextStyle(
                                color: AppColors.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                          )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Code évènement:${widget.eventCode}",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Text(
                      "Partagez le code de l'événement avec vos invités et ils recevront un pass d'entrée pour l'événement",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Image.file(
                    File(widget
                        .image.path), // Utilisation de File(widget.image.path)
                    width: width * 0.8,
                    height: height * 0.45,
                  ),
                  Text(widget.eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      )),
                  Text(
                    "Lieu: ${widget.eventAddress}",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      'Heure: ${DateFormat('dd-MM-yyyy  hh:mm a').format(widget.dateTime)}',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black)),
                    child: IconButton(
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
                                  'Obtenez un ticket d\'entrée pour ${widget.eventName}',
                              text: 'Entrez le code '
                                  '${widget.eventCode}'
                                  ' pour obtenir un ticket d\'entrée au ${widget.eventName} se déroulant le ${DateFormat('dd-MM-yyyy  hh:mm a').format(widget.dateTime)}',
                              linkUrl: 'https://eventos.com',
                              chooserTitle:
                                  'Obtenez un ticket d\'entrée pour ${widget.eventName}');
                        }),
                  ),
                  const Text(
                    "Inviter",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10)
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _controllerCenter,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class EventCreateTextField extends StatelessWidget {
  const EventCreateTextField(
      {super.key,
      required this.icon,
      required this.hint,
      this.obsecure = false,
      this.validator,
      required this.controller,
      this.maxLines,
      this.minLines,
      this.onSaved,
      required this.radius,
      required this.number,
      this.color,
      required this.width,
      this.onChanged});

  final TextEditingController controller;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final bool number;
  final double radius;
  final Color? color;
  final double width;

  final FormFieldValidator<String>? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      obscureText: obsecure,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      style: TextStyle(fontSize: 20, color: AppColors.primary),
      decoration: InputDecoration(
          labelStyle: GoogleFonts.cabin(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.primary),
          labelText: hint,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 20),
            borderSide: BorderSide(
              color: color ?? AppColors.primary,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius ?? 20),
            borderSide: BorderSide(
              color: color ?? AppColors.primary,
              width: width ?? 1.5,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 25, right: 10),
            child: IconTheme(
              data: IconThemeData(color: AppColors.primary),
              child: icon,
            ),
          )),
    );
  }
}
