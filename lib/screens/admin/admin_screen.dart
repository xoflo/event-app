import 'package:event_app/const.dart';
import 'package:flutter/material.dart';

import 'admin_event.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: secondaryColor,
        centerTitle: true,
        title: Text("Event Administrator", style: TextStyle(color: inverseColor, fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                addEventCard()
              ],
            ),
            SizedBox(height: 15),
            eventList()
          ],
        ),
      ),
    );
  }


  addEventCard(){
    return tappableCard("Add Event", "Create a new event", Icons.event_note, () {print("Add Event");});
  }

  eventList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Event List", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),
          Container(
            height: 400,
            child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, i) {
              return ListTile(
                title: Text("Event ${i+1}: Event Name"),
                subtitle: Text("Status: Ongoing"),
                trailing: IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EventScreen()));
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
