import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final primaryColor = Color(0xffeb5e28);
final secondaryColor = Color(0xffccc5b9);
final backgroundColor = Color(0xfffffcf2);
final tertiaryColor = Color(0xff403d39);
final inverseColor = Color(0xff252422);


tappableCard(String title, String subtitle, IconData icon, void Function() onTap) {
  return Builder(
      builder: (context) {
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
                  width: 280,
                  child: Row(
                    children: [
                      Icon(icon, color: backgroundColor, size: 50),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(color: backgroundColor, fontSize: 22, fontWeight: FontWeight.w700)),
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
      }
  );
}