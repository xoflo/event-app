import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:event_app/hive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import '../../const.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Event App", style: TextStyle(color: backgroundColor, fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: FutureBuilder(
        future: generateUID(1),
        builder: (BuildContext context, AsyncSnapshot<Stream<DocumentSnapshot<Map<String, dynamic>>>> userRef) {
          return userRef.data == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  actionRow(),
                  SizedBox(height: 10),
                  StreamBuilder(stream: userRef.data, builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting ?
                        Center(
                          child: Container(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ) : eventList(snapshot.data!);
                  })
                ],
              ),
            ),
          );
        } ,
      ),
    );
  }

  generateUID(int i) async {
    final deviceId = await DeviceIdService.getOrCreateDeviceId();
    final docRef = firebaseFirestore.collection('participants').doc(deviceId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': deviceId,
        'activeEvent' : "",
        'recentAction' : "",
        'voteStatus' : ""
      });
    }

    return i == 1 ? docRef.snapshots() : docRef;
  }


  actionRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        tappableCard("User QR", "Join Events", Icons.qr_code, qrDialog),
      ],
    );
  }

  qrDialog() {
    ScreenshotController controller = ScreenshotController();

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("User QR"),
      backgroundColor: backgroundColor,

      content: Screenshot(
        controller: controller,
        child: Container(
          height: 400,
          width: 300,
          child: Column(
            children: [
              Text("User ID", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              FutureBuilder(future: DeviceIdService.getOrCreateDeviceId(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return snapshot.connectionState == ConnectionState.waiting ? Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ) : Column(
                  children: [
                    BarcodeWidget(data: snapshot.data, barcode: Barcode.qrCode()) ,
                    SizedBox(height: 10),
                    Text(snapshot.data, style: TextStyle(color: Colors.grey),)
                  ],
                );
              }),
              SizedBox(height: 10),
              Text("Event Pass", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text("SCAN TO ENTER", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),

            ],
          ),
        ),
      ),
    ));
  }

  eventList(DocumentSnapshot<Map<String, dynamic>> userRef) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active Event", style: TextStyle(color: inverseColor, fontSize: 24, fontWeight: FontWeight.w700),),
        SizedBox(height: 10),
        userRef.get('activeEvent') == "" ? noEventCard() : eventCard(userRef)
      ],
    );
  }

  eventCard(DocumentSnapshot<Map<String, dynamic>> userRef) {
    return Card(
      color: Colors.white,
      child: SizedBox(
        height: 520,
        width: 400,
        child: Padding(
            padding: EdgeInsets.all(20),
                child: StreamBuilder(
                  stream: eventsCollection.doc(userRef.get('activeEvent')).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting ? Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ) : Column(
                      children: [
                        Text(snapshot.data!.get('eventName'), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: inverseColor)),
                        Text("Date: ${DateFormat.yMMMd().format(snapshot.data!.get('eventCreated').toDate()) }  |  Participants: ${snapshot.data!.get('participants')}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inverseColor)),
                        SizedBox(height: 10),
                        Text("Current Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: inverseColor)),
                        SizedBox(height: 10),
                        activityHandler(snapshot.data!.get('activeAction') == "" ? 1 : 2, snapshot.data!, userRef)
                      ],
                    );
                  },
                ),


        ),
      ),
    );
  }


  activityHandler(int i, DocumentSnapshot<Map<String, dynamic>> event, DocumentSnapshot<Map<String, dynamic>> userRef) {

    if (i == 1) {
      return Container(
          height: 250,
          child: Center(
              child: Text("No Activity at the moment")));
    }

    if (i == 2) {
      final recentAction = userRef.get('recentAction');
      final activeAction = event.get('activeAction');

      if (recentAction != activeAction) {
        userRef.reference.update({
          'recentAction' : activeAction,
          'voteStatus' : ""
        });

      }



      return StreamBuilder(
        stream: eventsCollection.doc(event.get('eventName')).collection('actions').doc(event.get('activeAction')).snapshots(),
        builder: (context, action) {
          return action.connectionState == ConnectionState.waiting ? Center(
            child: Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          ) : Column(
            children: [
              Text("Poll: ${action.data!.get('actionName')}", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: inverseColor)),
              SizedBox(height: 10),
              Text("Time Remaining", style: TextStyle(fontSize: 15)),
               StatefulBuilder(
                  builder: (BuildContext context,
                  void Function(void Function()) setState) {

                int timeDisplay = action.data!.get('durationInSeconds');

                return FutureBuilder(
                    future: getNetworkTime(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime> utcTime) {

                      if (utcTime.connectionState == ConnectionState.waiting) {
                        return Text("00:00:00",
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700));
                      }

                      if (!utcTime.hasData || utcTime.data == null) {
                        return Text("00:00:00",
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700));
                      }

                      if (action.data!.get('status') == "Ongoing") {
                        final startTime = action.data!.get('startTime');
                        final differenceInSeconds = utcTime.data!
                            .difference(startTime.toDate())
                            .inSeconds;
                        timeDisplay = action.data!.get('durationInSeconds') -
                            differenceInSeconds;

                        if (timeDisplay <= 0 && action.data!.get('status') == "Ongoing") {
                          action.data!.reference.update({'status': "Completed"});
                          event.reference.update({'activeAction' : ""});
                          timer?.cancel();

                          setState((){});
                        }

                        timer = Timer(Duration(seconds: 1), () {
                          setState(() {
                            timeDisplay--;
                          });
                        });
                      }

                      return action.connectionState == ConnectionState.waiting
                          ? Container(
                          height: 10,
                          width: 50,
                          child: LinearProgressIndicator())
                          : Text("${secondsToDisplay(timeDisplay)}",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w700));
                    });
              }),

              SizedBox(height: 10),
              Builder(
                builder: (context) {


                  List<int> index = [];
                  String? finalChoice = userRef.get('voteStatus');
                  final Map<String, dynamic> options =  action.data!.get('options');

                  return StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 140,
                            child: Builder(
                                builder: (context) {
                                  return finalChoice != "" ? Column(
                                    children: [
                                      Text("You Picked:", textAlign: TextAlign.center, style: TextStyle(fontSize: 30, overflow: TextOverflow.ellipsis ,fontWeight: FontWeight.w500)),
                                      Text("$finalChoice", textAlign: TextAlign.center, style: TextStyle(fontSize: 40, overflow: TextOverflow.ellipsis ,fontWeight: FontWeight.w700)),
                                    ],
                                  ) : Material(
                                    color: Colors.white,
                                    child: ListView.builder(
                                        itemCount: options.length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                                            child: ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)
                                              ),
                                              selected: index.contains(i),
                                              selectedTileColor: primaryColor,
                                              hoverColor: primaryColor,
                                              title: Text(options['opt$i']['name'], style: TextStyle(color: index.contains(i) ? inverseColor : inverseColor)),
                                              onTap: () {
                                                index.clear();
                                                setState(() {
                                                  index.add(i);
                                                });
                                              },
                                            ),
                                          );
                                        }),
                                  );
                                }
                            ),
                          ),

                          SizedBox(height: 15),
                          Text("${index.isEmpty ? finalChoice == "" ? "No Choice" : "" : options['opt${index.first}']['name']}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          index.isEmpty ? SizedBox() : IconButton(
                            onPressed: () {
                              showDialog(context: context, builder: (_) => AlertDialog(
                                backgroundColor: backgroundColor,
                                content: Container(
                                  height: 150,
                                  width: 150,
                                  child: Column(
                                    children: [
                                      Text("You Selected:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                      SizedBox(height: 10),
                                      Text(options['opt${index.first}']['name'], overflow: TextOverflow.ellipsis ,style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                                      SizedBox(height: 10),
                                      Text("THIS ACTION CANNOT BE UNDONE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
                                      SizedBox(height: 15),
                                      ElevatedButton(
                                          style: ButtonStyle(
                                              foregroundColor: WidgetStateProperty.all(inverseColor),
                                              backgroundColor: WidgetStateProperty.all(primaryColor)),

                                          onPressed: () async {
                                            Navigator.pop(context);


                                            await action.data!.reference.update({
                                              'options.opt${index.first}.votes' : FieldValue.increment(1)
                                            });

                                            await userRef.reference.update({
                                              'voteStatus' : options['opt${index.first}']['name'].toString()
                                            });

                                            Navigator.pop(context);
                                            index.clear();

                                      }, child: Text("Submit"))

                                    ],
                                  ),
                                ),
                              ));
                            },
                            icon: Icon(
                                color: primaryColor,
                                Icons.check)),

                          finalChoice != "" ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("This is saved and recorded", style: TextStyle(color: primaryColor, fontSize: 20, fontStyle: FontStyle.italic)),
                              SizedBox(width: 10),
                              Icon(Icons.check_circle, color: primaryColor)
                            ],
                          ) : Text("")

                        ],
                      );
                    },

                  );
                }
              ),
            ],
          );
        }
      );
    }
  }


  noEventCard() {
    return Card(
      color: Colors.white,
      child: Container(
        height: 300,
        width: 400,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.event, size: 60),
              SizedBox(height: 10),
              Text("No Active Event", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: inverseColor)),
              Text("Get your QR Scanned\nat Event Gate to Join", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: inverseColor))


            ],
          ),
        ),
      ),
    );
  }

}
