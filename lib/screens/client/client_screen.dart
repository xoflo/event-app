import 'package:barcode_widget/barcode_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:event_app/hive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import '../../const.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Event App", style: TextStyle(color: inverseColor, fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              actionRow(),
              SizedBox(height: 10),
              eventList()
            ],
          ),
        ),
      ),
    );
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

  eventList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active Event", style: TextStyle(color: inverseColor, fontSize: 24, fontWeight: FontWeight.w700),),
        SizedBox(height: 10,),
        eventCard()
      ],
    );
  }

  eventCard() {
    return Card(
      color: secondaryColor,
      child: Container(
        height: 500,
        width: 400,
        child: Padding(
            padding: EdgeInsets.all(20),
                child: Column(
            children: [
              Text("Elections 2025", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: inverseColor)),
              Text("Date: 12/12/2023  |  Participants: 888", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: inverseColor)),
              SizedBox(height: 10),
              Text("Current Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: inverseColor)),
              SizedBox(height: 10),
              activityHandler(2)


            ],
        ),
        ),
      ),
    );
  }


  activityHandler(int i) {

    if (i == 1) {
      return Container(
          height: 250,
          child: Center(
              child: Text("No Activity at the moment")));
    }

    if (i == 2) {
      return Column(
        children: [
          Text("Poll: President", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: inverseColor)),
          SizedBox(height: 10),
          Text("1:59", style: TextStyle(fontSize: 30)),
          Text("Time Remaining", style: TextStyle(fontSize: 15)),
          SizedBox(height: 10),
          Builder(
            builder: (context) {

              List<int> index = [];

              return StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) {
                  return Column(
                    children: [
                      Container(
                        height: 160,
                        child: Builder(
                            builder: (context) {

                              return Material(
                                color: secondaryColor,
                                child: ListView.builder(
                                    itemCount: 8,
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
                                          title: Text("Option $i", style: TextStyle(color: index.contains(i) ? inverseColor : inverseColor)),
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
                      Text("${index.isEmpty ? "No Choice" : "Option ${index.first}"}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      index.isEmpty ? SizedBox() : IconButton(
                        onPressed: () {
                          showDialog(context: context, builder: (_) => AlertDialog(
                            backgroundColor: backgroundColor,
                            content: Container(
                              height: 150,
                              width: 150,
                              child: Column(
                                children: [
                                  Text("Your Selected:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 10),
                                  Text("Option ${index.first}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 10),
                                  Text("Submitting is final and cannot be undone", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ElevatedButton(onPressed: () {}, child: Text("Submit"))

                                ],
                              ),
                            ),
                          ));
                        },
                        icon: Icon(
                            color: primaryColor,
                            Icons.check))

                    ],
                  );
                },

              );
            }
          ),
        ],
      );
    }
  }


  noEventCard() {
    return Card(
      color: secondaryColor,
      child: Container(
        height: 300,
        width: 400,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 60),
              SizedBox(height: 10),
              Text("No Active Event", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: inverseColor)),
              Text("Join an Event using your QR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: inverseColor))


            ],
          ),
        ),
      ),
    );
  }

}
