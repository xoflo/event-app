
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntp_dart/models/accurate_time.dart';
import 'dart:math' as math;
import 'package:ntp_dart/models/libraries/ntp_io.dart';

final primaryColor = Color(0xffeb5e28);
final secondaryColor = Color(0xffccc5b9);
final backgroundColor = Color(0xfffffcf2);
final tertiaryColor = Color(0xff403d39);
final inverseColor = Color(0xff252422);


isLandscape(BuildContext context) {
  if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
    return true;
  } else {
    return false;
  }
}

// Functions

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
  print(nowUtc);
  return nowUtc;
}













// Widgets

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


