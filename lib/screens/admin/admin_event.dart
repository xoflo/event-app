import 'package:barcode_widget/barcode_widget.dart';
import 'package:event_app/const.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import 'admin_action.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, this.eventDoc});

  final String? eventDoc;

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
        title: Text('Event', style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: StreamBuilder(
        stream: eventsCollection.doc(widget.eventDoc).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator()));

          } else {
            String? eventStatus = snapshot.data['status'];


            return Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(snapshot.data['eventName'], style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),
                    Text("Status: ${snapshot.data['status']}"),
                    Text("${DateFormat().add_yMMMMd().format(DateTime.now())} ${DateFormat().add_jm().format(DateTime.now())}"),

                    Text("Total Participants: ${snapshot.data['participants']}"),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: eventStatus == "Complete" ? Text("Event Completed", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700, color: Colors.green)) :  SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 5,
                          children: [
                            tappableCard("Create Poll", "Let Participants Vote", Icons.poll, createPollDialog),
                            eventStatus == "Preparing" ? tappableCard("Start Event", "Allow Joining", Icons.play_arrow, startEvent) : tappableCard("Pause Event", "Halt Joining", Icons.pause, startEvent),
                            tappableCard("End Event", "Save Event", Icons.flag, endEvent)
                          ],
                        ),
                      ),
                    ),
                    actionList()


                  ],
                ),
              ),
            );
          }


        },
      )
    );
  }



  actionList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Actions", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),
          StreamBuilder(
            stream: eventsCollection.doc(widget.eventDoc).collection('actions').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator()));

              } else {
                return snapshot.data!.docs.length == 0 ? Container(
                  height: 50,
                  child: Center(
                    child: Text("No actions found", style: TextStyle(color: Colors.grey)),
                  ),
                ) : Container(
                  height: 400,
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text(snapshot.data!.docs[i].get("pollName")),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAction()));
                          },
                        );
                      }),
                );;
              }
            },
          ),
        ],
      ),
    );
  }

  actionDialog() {

  }

  scanQr() {
    if (kIsWeb) {

    }
  }

  startEvent() async {
    loadingWidget(context);


    final status = await eventsCollection.doc(widget.eventDoc).get().then((value) {
      return value.get('status');
    });

    if (status == "Preparing") {
      await eventsCollection.doc(widget.eventDoc).update({
        'status' : "Ongoing"
      });
    } else {
      await eventsCollection.doc(widget.eventDoc).update({
        'status' : "Preparing"
      });
    }
    Navigator.pop(context);
  }

  endEvent() async {
    confirmDialog(context, "This event will be completed", () async {
      loadingWidget(context);
      await eventsCollection.doc(widget.eventDoc).update({
        'status' : "Complete"
      });
      Navigator.pop(context);
    });
  }



  createPollDialog() {

    TextEditingController pollName = TextEditingController();
    TextEditingController hours = TextEditingController();
    TextEditingController minutes = TextEditingController();
    TextEditingController seconds = TextEditingController();
    List<String> options = [];

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Create Poll"),
      backgroundColor: backgroundColor,
      content: Container(
        height: 400,
        width: 300,
        child: StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12.5, 0, 12.5, 0),
                  child: TextField(
                    controller: pollName,
                    decoration: InputDecoration(
                        labelText: "Poll Name"
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12.5, 0, 12.5, 0),
                  child: Row(
                    spacing: 10,
                    children: [
                      Container(
                          height: 50,
                          width: 80,
                          child: TextFieldNumber("Hours", hours)),

                      Container(
                          height: 50,
                          width: 80,
                          child: TextFieldNumber("Minutes", minutes)),

                      Container(
                          height: 50,
                          width: 80,
                          child: TextFieldNumber("Seconds", seconds)),
                    ],
                  ),
                ),
                Builder(
                    builder: (context) {
                      TextEditingController optionController = TextEditingController();

                      return ListTile(
                        title: TextField(
                          controller: optionController,
                          decoration: InputDecoration(
                              label: Text('Option Name')
                          ),
                        ),
                        trailing: IconButton(onPressed: () {
                          if (optionController.text.isNotEmpty) {
                            setState(() {
                              options.add(optionController.text);
                            });
                          }
                        }, icon: Icon(Icons.add)),
                      );
                    }
                ),
                SizedBox(height: 10),
                Text("Options:"),
                Container(
                  height: 200,
                  child: options.length == 0 ? Center(
                    child: Text("Add options to poll", style: TextStyle(color: Colors.grey)),
                  ) : ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text("${options[i]}"),
                          subtitle: Text("Option ${i+1}"),
                          trailing: IconButton(onPressed: () {
                            setState((){
                              options.remove(options[i]);
                            });
                          }, icon: Icon(Icons.delete)),
                        );
                      }),
                ),

              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () async {

          final hoursInSeconds = int.parse(hours.text.isEmpty ? "0" : hours.text);
          final minutesInSeconds = int.parse(minutes.text.isEmpty ? "0" : minutes.text);
          final secondsInSeconds = int.parse(seconds.text.isEmpty ? "0" : seconds.text);

          final totalSeconds = hoursInSeconds * 3600 + minutesInSeconds * 60 + secondsInSeconds;

          loadingWidget(context);

          await eventsCollection.doc(widget.eventDoc).collection('actions').add({
            'actionName' : pollName.text,
            'durationInSeconds' : totalSeconds,
            'options' : options,
            'status' : "Preparing"
          });

          Navigator.pop(context);
          Navigator.pop(context);
          snackBarWidget(context, "Action Added");

        }, child: Text("Save Poll"))
      ],
    ));
  }

}
