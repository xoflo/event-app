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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            actionRow(),
            SizedBox(height: 10),
            eventList()
          ],
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
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Active Event", style: TextStyle(color: inverseColor, fontSize: 24, fontWeight: FontWeight.w700),),
          SizedBox(height: 10,),
          eventCard()
        ],
      ),
    );
  }

  eventCard() {
    return Card(
      color: secondaryColor,
      child: Container(
        height: 400,
        width: 400,
        child: Padding(
            padding: EdgeInsets.all(20),
                child: Column(
            children: [
              Text("Event Name", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Current Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),


            ],
        ),
        ),
      ),
    );
  }

  activityHandler() {

  }


}
