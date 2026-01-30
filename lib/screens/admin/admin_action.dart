import 'package:flutter/material.dart';

import '../../const.dart';

class AdminAction extends StatefulWidget {
  const AdminAction({super.key});

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
        title: Text('Action: Action Name', style: TextStyle(fontWeight: FontWeight.w700),),
      ),

      body: Padding(
          padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Action Name", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),
                Text("Duration: 00:00:00"),
                Text("Status: Complete"),
                SizedBox(height: 10),
                actions(),
                optionList()


          ],
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
            tappableCard("Live View", "See Results", Icons.pie_chart, () {})
          ],
        ),
      ),
    );
  }

  startAction() {
    setState(() {
      actionStart = !actionStart;
    });
  }

  optionList() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Options", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),

          Container(
            height: 400,
            child: ListView.builder(
              itemCount: 1,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text("Option"),
                    subtitle: Text("Option ${i+1}"),
                    onTap: () {
                      editOptionDialog();
                    },
                  );
                }),

          )
        ],
      ),
    );
  }


  editOptionDialog() {
    TextEditingController controller = TextEditingController();

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

          Navigator.pop(context);
        }, child: Text("Update Option"))
      ],
    ));
  }
}
