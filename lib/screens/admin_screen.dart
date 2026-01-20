import 'package:event_app/const.dart';
import 'package:flutter/material.dart';

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
        title: Text("Admin Screen", style: TextStyle(color: inverseColor, fontWeight: FontWeight.w700)),
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
    return Builder(
        builder: (context) {
          var color = tertiaryColor;
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return InkWell(
                onHover: (value) => setState(() {
                  color = value ? primaryColor : tertiaryColor;
                }),
                child: Card(
                  color: color,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: 100,
                    width: 350,
                    child: Row(
                      children: [
                        Icon(Icons.event_note, color: backgroundColor, size: 60),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Event", style: TextStyle(color: backgroundColor, fontSize: 22, fontWeight: FontWeight.w700)),
                            Text("Allow Participants, Make Actions", style: TextStyle(color: backgroundColor))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  print("Add Event");
                },
              );
            },
          );
        }
    );
  }

  eventList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Event List", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),
        Container(
          height: 400,
          child: ListView.builder(itemBuilder: (context, i) {
            return ListTile();
          }),
        ),
      ],
    );
  }
}
