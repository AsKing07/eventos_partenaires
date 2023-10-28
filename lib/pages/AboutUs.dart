import 'package:eventos_partenaires/config/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("À propos de nous"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png', // Assurez-vous de placer votre logo dans le répertoire des actifs.
                width: 150,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Bienvenue dans l'univers d'EventOs!",
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "EventOs est le fruit du travail acharné d'un groupe de 7 étudiants en Informatique de l'Institut de Formation et de Recherche en Informatique (IFRI). Nous sommes fiers de présenter cette application qui offre deux expériences uniques : EventOs User et EventOs Partenaire.",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "EventOs User permet à des particuliers d'acheter des Pass en ligne pour une variété d'évènements. Vous recevez un pass digital qui sera scanné à l'entrée de l'évènement, rendant l'accès rapide et pratique.",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "EventOs Partenaire s'adresse aux organisateurs d'évènements. Vous pouvez mettre en vente des tickets pour tout type d'évènement, scanner les tickets avec l'application, et profiter de nombreuses autres fonctionnalités. Les détenteurs de l'application reçoivent un pourcentage (8%) sur le revenu de l'application, tandis que le reste est reversé aux organisateurs 24 heures après la fin de l'évènement.",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const whatsappUrl = "https://wa.me/65861948"; // Lien WhatsApp
                  if (await canLaunch(whatsappUrl)) {
                    await launch(whatsappUrl);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Contactez-nous sur WhatsApp',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const websiteUrl =
                      "https://cutt.ly/charbeldev"; // Lien vers le site web
                  if (await canLaunch(websiteUrl)) {
                    await launch(websiteUrl);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Retrouvez tous nos projets sur GitHub',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const websiteUrl =
                      ":https://github.com/AsKing07"; // Lien vers le site web
                  if (await canLaunch(websiteUrl)) {
                    await launch(websiteUrl);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Visitez notre site web',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
