import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/const.dart';
import 'package:event_app/firebase_options.dart';
import 'package:event_app/screens/admin/admin_screen.dart';
import 'package:event_app/screens/client/client_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  await Hive.initFlutter();
  await Hive.openBox('deviceBox');

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      debugShowCheckedModeBanner: false,
      title: 'Event App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: backgroundColor,
            inversePrimary: inverseColor,
            seedColor: primaryColor),
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: const AdminScreen(),
    );
  }
}

