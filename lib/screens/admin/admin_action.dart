import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/screens/admin/admin_result.dart';
import 'package:flutter/material.dart';

import '../../const.dart';

class AdminAction extends StatefulWidget {
  const AdminAction({super.key, this.eventRef, this.actionRef, this.actionName});

  final String? actionName;
  final DocumentReference<Map<String, dynamic>>? eventRef;
  final DocumentReference<Map<String, dynamic>>? actionRef;

  @override
  State<AdminAction> createState() => _AdminActionState();
}

class _AdminActionState extends State<AdminAction> {

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
        backgroundColor: secondaryColor,
        title: Text(widget.actionName!, style: TextStyle(fontWeight: FontWeight.w700),),
      ),

      body: Padding(
          padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StreamBuilder(
            stream: widget.actionRef!.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return snapshot.connectionState == ConnectionState.waiting ?
                  Container(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(snapshot.data['actionName'], style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),

                  Text("Duration: ${formatSeconds(snapshot.data['durationTotal'])}"),
                  // Timer Widget Below:

                  StreamBuilder(
                    stream: widget.actionRef!.snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                      return snapshot.connectionState == ConnectionState.waiting
                          ? Text("00:00:00",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w700))
                          : StatefulBuilder(builder: (BuildContext context,
                          void Function(void Function()) setState) {

                        int timeDisplay = snapshot.data['durationInSeconds'];


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

                              if (snapshot.data['status'] == "Ongoing") {
                                final startTime = snapshot.data['startTime'];
                                final differenceInSeconds = utcTime.data!
                                    .difference(startTime.toDate())
                                    .inSeconds;
                                timeDisplay = snapshot.data['durationInSeconds'] -
                                    differenceInSeconds;

                                if (timeDisplay <= 0) {
                                  widget.actionRef!.update({'status': "Complete"});
                                  widget.eventRef!.update({'activeAction' : ""});
                                  timer?.cancel();

                                  setState(() {});
                                }

                                timer = Timer(Duration(seconds: 1), () {
                                  setState(() {
                                    timeDisplay--;
                                  });
                                });
                              }


                              return snapshot.connectionState == ConnectionState.waiting
                                  ? Container(
                                  height: 10,
                                  width: 50,
                                  child: Text("00:00:00",
                                      style: TextStyle(
                                          fontSize: 40, fontWeight: FontWeight.w700)))
                                  : Text(snapshot.data['status'] == "Complete" ? "00:00:00" : "${secondsToDisplay(timeDisplay)}",
                                  style: TextStyle(
                                      fontSize: 40, fontWeight: FontWeight.w700));
                            });
                      });
                    },
                  ),


                  Text("Status: ${snapshot.data['status']}"),
                  SizedBox(height: 10),
                  actions(snapshot.data['status']),
                  optionList(snapshot)


                ],);
            },

          ),
        ),
      )
    );
  }

  actions(String status) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            status == "Complete" ? tappableCard('Reset Vote', "Restart Time", Icons.restart_alt, resetAction) :
            status == "Ongoing" ? tappableCard("Pause Action", "Pause voting", Icons.pause,  startAction) : tappableCard("Start Action", "Open voting", Icons.play_arrow, startAction),
            tappableCard("Live View", "See Results", Icons.pie_chart, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminResult(
                actionName: widget.actionName,
                actionRef: widget.actionRef,
              )));
            })
          ],
        ),
      ),
    );
  }

  eventCompleteCondition() async {
    return await widget.eventRef!.get().then((value) {
      return value.get('status');
    }) == "Complete";
  }

  resetAction() async {

    if (await eventCompleteCondition()) {
      snackBarWidget(context, "Event already complete");
    } else {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text("Confirm"),
        content: Container(
          height: 100,
          width: 200,
          child: Column(
            children: [
              Icon(Icons.warning, size: 40),
              SizedBox(height: 10),
              Text("Reset Vote?", style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
              Text("This action cannot be undone.", style: TextStyle(color: Colors.grey))
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () async {
            await widget.actionRef!.update({
              'status' : 'Preparing',
              'durationInSeconds' : await widget.actionRef!.get().then((value) {
                return value.get('durationTotal');
              })
            });
          }, child: Text("Confirm"))
        ],

      ));
    }

  }


  startAction() async {

    if (eventCompleteCondition()) {
      snackBarWidget(context, "Event already complete");
      return;
    } else {

      late String status;
      late String actionName;

      await widget.actionRef!.get().then((value) {
        status = value.get('status');
        actionName = value.get('actionName');
      });

      loadingWidget(context);

      if (status == "Preparing") {

        if (await widget.eventRef!.get().then((value) {
          return value.get('activeAction');
        }) != "") {
          Navigator.pop(context);
          snackBarWidget(context, "There is a current action active.");
          return;
        }


        await widget.actionRef!.update({
          'startTime' : await getNetworkTime(),
          'status' : "Ongoing"
        });

        await widget.eventRef!.update({
          'activeAction' : actionName
        });

        Navigator.pop(context);


      } else {

        timer?.cancel();

        await widget.eventRef!.update({
          'activeAction' : ""
        });

        final Timestamp recentStartTime = await widget.actionRef!.get().then((value) {
          return value.get('startTime');
        });

        final DateTime utcNow = await getNetworkTime();
        final differenceInSeconds = utcNow.difference(recentStartTime.toDate()).inSeconds;

        final duration = await widget.actionRef!.get().then((value) {
          return value.get('durationInSeconds');
        });

        await widget.actionRef!.update({
          'status' : "Preparing",
          'durationInSeconds' : duration - differenceInSeconds
        });

        Navigator.pop(context);

      }


    }


  }

  optionList(AsyncSnapshot<dynamic> snapshot) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Options", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),

          Container(
            height: 400,
            child: ListView.builder(
              itemCount: snapshot.data['options'].length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(snapshot.data['options.opt$i.name']),
                    subtitle: Text("Option ${i+1}"),
                    trailing: Text(snapshot.data['options.opt$i.votes'].toString(), style: TextStyle(fontSize: 20),),
                    onTap: () async {
                      if (await eventCompleteCondition()) {
                        snackBarWidget(context, "Event already complete");
                      } else {
                        editOptionDialog(snapshot, i);
                      }
                    },
                  );
                }),

          )
        ],
      ),
    );
  }


  editOptionDialog(AsyncSnapshot<dynamic> snapshot, int i) {
    TextEditingController controller = TextEditingController();

    controller.text = snapshot.data['options.opt$i.name'];

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Edit Option"),
      content: Container(
        height: 60,
        width: 80,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Option Name'
              ),
              controller: controller,
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () {

          widget.actionRef!.update({
            'options.opt$i.name' : controller.text,
          });

          Navigator.pop(context);
        }, child: Text("Update Option"))
      ],
    ));
  }
}
