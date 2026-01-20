import 'package:event_app/const.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text('Event: Event Name', style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget()


          ],
            ),
      ),
    );
  }


  titleWidget() {
    return [
      Text("Event Name", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),
      Text("Status: Ongoing")
    ];
  }
}
