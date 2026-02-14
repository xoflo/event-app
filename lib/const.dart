
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntp_dart/models/accurate_time.dart';
import 'dart:math' as math;
import 'package:ntp_dart/models/libraries/ntp_io.dart';

final primaryColor = Color(0xff606c38);
final secondaryColor = Color(0xffccc5b9);
final backgroundColor = Color(0xfffffcf2);
final tertiaryColor = Color(0xff403d39);
final inverseColor = Color(0xff252422);

// Firebase

final firebaseFirestore = FirebaseFirestore.instance;
final eventsCollection = firebaseFirestore.collection('digos');


// Functions

isLandscape(BuildContext context) {
  if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
    return true;
  } else {
    return false;
  }
}


Set<Color> usedColors = {};

final List<Color> colorOrder = [
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.green,
  Colors.orange,
  Colors.purple,
  ...Colors.primaries
];

Color generateUniqueColor() {
  for (Color color in colorOrder) {
    if (!usedColors.contains(color)) {
      usedColors.add(color);
      return color;
    }
  }

  return Colors.grey;
}

clearUsedColors (){
  usedColors.clear();
}

Future<DateTime> getNetworkTime() async {
  final nowUtc = AccurateTime.nowSync();
  return nowUtc;
}


String formatSeconds(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  // Get remaining minutes after accounting for hours
  final minutes = duration.inMinutes.remainder(60);
  // Get remaining seconds after accounting for minutes
  final remainingSeconds = duration.inSeconds.remainder(60);

  // Format with leading zeros for all parts
  final hoursStr = hours.toString().padLeft(2, '0');
  final minutesStr = minutes.toString().padLeft(2, '0');
  final secondsStr = remainingSeconds.toString().padLeft(2, '0');

  // Return the formatted string in HH:MM:SS format
  return '$hoursStr:$minutesStr:$secondsStr';
}

String secondsToDisplay(int? seconds) {
  final safeSeconds = seconds ?? 0;
  final duration = Duration(seconds: safeSeconds);

  return '${duration.inHours.toString().padLeft(2, '0')}:'
      '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
      '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}





// Widgets

confirmDialog(BuildContext context, String content, void Function() onConfirm) {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: Text("Confirm"),
    content: Container(
      height: 100,
      width: 200,
      child: Column(
        children: [
          Icon(Icons.warning, size: 40),
          SizedBox(height: 10),
          Text("$content", style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
          Text("This action cannot be undone.", style: TextStyle(color: Colors.grey))
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () {
        onConfirm();
      }, child: Text("Confirm"))
    ],

  ));
}

loadingWidget(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context, builder: (_) => AlertDialog(
    content: Container(
      height: 100,
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 50,
            width: 50,
            child: CircularProgressIndicator()),
        SizedBox(height: 10),
        Text("Loading...")

      ],
    ),
  )));
}

snackBarWidget(BuildContext context, String content) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}


TextFieldNumber(String label, TextEditingController? controller) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ],
    decoration: InputDecoration(labelText: label),
  );

}

tappableCard(
    String title, String subtitle, IconData icon, void Function() onTap) {
  return Builder(builder: (context) {
    var color = tertiaryColor;
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return InkWell(
          onHover: (value) => setState(() {
            color = value ? primaryColor : tertiaryColor;
          }),
          onTap: onTap,
          child: Card(
            color: color,
            child: Container(
              padding: EdgeInsets.all(20),
              height: 100,
              width: 250,
              child: Row(
                children: [
                  Icon(icon, color: backgroundColor, size: 50),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: backgroundColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      Text(subtitle, style: TextStyle(color: backgroundColor))
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  });
}


