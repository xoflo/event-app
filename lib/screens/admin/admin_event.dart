import 'package:event_app/const.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

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
        title: Text('Event: Event Name', style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Event Name", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),),
            Text("Status: Ongoing"),
            Text("Participants: 92"),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    tappableCard("Create Poll", "Let Participants Vote", Icons.poll, createPollDialog),
                    tappableCard("Event QR", "Share with Participants", Icons.qr_code, () => print("QR")),
                  ],
                ),
              ),
            ),
            actionList()


          ],
        ),
      )
    );
  }



  actionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Actions", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25, color: inverseColor)),
        Container(
          height: 400,
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, i) {
            return ListTile(
              title: Text("Action $i"),
              onTap: () {

              },
            );
          }),
        ),
      ],
    );
  }

  createPollDialog() {

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
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Poll Name"
                    ),
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
        TextButton(onPressed: () {}, child: Text("Save Poll"))
      ],
    ));
  }

}
