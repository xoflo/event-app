import 'package:event_app/const.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/screens/admin/admin_action.dart';
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              actions(),
              SizedBox(height: 15),
              eventList()
            ],
          ),
        ),
      ),
    );
  }

  actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        addEventCard()
      ],
    );
  }

  addEventCard(){
    TextEditingController controller = TextEditingController();

    return tappableCard("Add Event", "Create a new event", Icons.event_note, () {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text("Add Event"),
        content: Container(
          height: 60,
          width: 200,
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Event Name'
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () {
            addEventFirebase(controller.text);
          }, child: Text("Save"))
        ],
      ));
    });
  }

  addEventFirebase(String eventName) async {

    loadingWidget(context);
    await eventsCollection.add(
        Event(
            eventName: eventName,
            eventCreated: DateTime.now(),
            participants: 0,
            status: "Ongoing"
        ).toFirebase()
    );
    snackBarWidget(context, "Event Added");
    Navigator.pop(context);
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
            child: StreamBuilder(
              stream: eventsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, i) {

                        Event event = Event().fromJson(snapshot.data!.docs[i].data());

                        return ListTile(
                          title: Text(event.eventName!),
                          subtitle: Text("Status: ${event.status}"),
                          trailing: IconButton(onPressed: () {}, icon: Icon(
                              Icons.delete)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => EventScreen()));
                          },
                        );
                      });
                } else {
                  return Center(
                    child: Text("No data found."),
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }
}
