import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/screens/admin/admin_result.dart';
import 'package:flutter/material.dart';

import '../../const.dart';

class AdminAction extends StatefulWidget {
  const AdminAction({super.key, this.actionRef});

  final DocumentReference<Map<String, dynamic>>? actionRef;

  @override
  State<AdminAction> createState() => _AdminActionState();
}

class _AdminActionState extends State<AdminAction> {

  bool actionStart = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text('Action', style: TextStyle(fontWeight: FontWeight.w700),),
      ),

      body: Padding(
          padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StreamBuilder(
            stream: widget.actionRef!.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(snapshot.data['actionName'], style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),
                  Text("Duration: ${secondsToDisplay(snapshot.data['durationInSeconds'])}"),
                  Text("Status: ${snapshot.data['status']}"),
                  SizedBox(height: 10),
                  actions(),
                  optionList(snapshot)


                ],);
            },

          ),
        ),
      )
    );
  }

  actions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            actionStart == true ? tappableCard("Pause Action", "Pause voting", Icons.pause, startAction) : tappableCard("Start Action", "Open voting", Icons.play_arrow, startAction),
            tappableCard("Live View", "See Results", Icons.pie_chart, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminResult()));
            })
          ],
        ),
      ),
    );
  }

  startAction() async {

    final status = await widget.actionRef!.get().then((value) {
      return value.get('status');
    });

    if (status == "Preparing") {
      widget.actionRef!.update({
        'status' : "Ongoing"
      });
    } else {
      widget.actionRef!.update({
        'status' : "Preparing"
      });
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
                    onTap: () {
                      editOptionDialog(snapshot, i);
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
