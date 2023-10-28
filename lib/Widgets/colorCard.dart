import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double baseHeight = 650.0;
double screenAwareSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.height / baseHeight;
}

Widget colorCard(
    String text, double amount, int type, BuildContext context, Color color) {
  final _media = MediaQuery.of(context).size;
  return Container(
    margin: const EdgeInsets.only(top: 15, right: 15),
    padding: const EdgeInsets.all(15),
    height: screenAwareSize(90, context),
    width: _media.width / 2 - 25,
    decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 0.2,
              offset: const Offset(0, 8)),
        ]),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "FCFA ${NumberFormat.compact().format(amount)}",
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  );
}
