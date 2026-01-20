import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/const.dart';
import 'package:event_app/firebase_options.dart';
import 'package:event_app/screens/admin/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

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

      debugShowCheckedModeBanner: false,
      title: 'Event App',
      theme: ThemeData(
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: const AdminScreen(),
    );
  }
}

