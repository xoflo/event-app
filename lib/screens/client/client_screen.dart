import 'package:barcode_widget/barcode_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
      body: tappableCard("User QR", "Join Events", Icons.qr_code, qrDialog),
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
              Text("Event Name", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              BarcodeWidget(data: checkId(), barcode: Barcode.qrCode()),
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

  checkId() {
    if (true) {

    } else {
      return generateId();
    }
  }

  generateId() {
    var uuid = Uuid();
    var id = uuid.v4();

    return id;
  }

}
