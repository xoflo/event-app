import 'package:event_app/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminResult extends StatefulWidget {
  const AdminResult({super.key});

  @override
  State<AdminResult> createState() => _AdminResultState();
}

class _AdminResultState extends State<AdminResult> {

  List<Color> pieChartColors = [];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Action Name: Action Name"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: isLandscape(context) ? Axis.horizontal : Axis.vertical,
          child: Column(
            children: [
              Row(
                spacing: 10,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.pie_chart)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.bar_chart)),
                ],
              ),
              screenSizeHandler()
            ],
          ),
        ),
      ),
    );
  }


  screenSizeHandler() {
    return isLandscape(context) ?
    StatefulBuilder(builder: (context, setState) {
      return Row(
        children: [
          pieChartWidget(setState),
          ...detailWidget()
        ],
      );
    }) : StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          pieChartWidget(setState),
          ...detailWidget()
        ],
      );
    });
  }

  pieChartWidget(void Function(void Function()) setState) {
    return Container(
      height: 400,
      child: PieChart(
          curve: Curves.linear,
          duration: Duration(milliseconds: 250),
          PieChartData(
              startDegreeOffset: 30,
              centerSpaceRadius: 0,
              pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      selectedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    });
                  }
              ),
              sections: pieDataBuilder(selectedIndex)
          )
      ),
    );
  }

  detailWidget(){
    return [selectedIndex == - 1 ?
    Container(
      padding: EdgeInsets.all(20),
      height: 400,
      child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text("President Option", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              trailing: Text("${i * 20}", style: TextStyle(fontSize: 30, color: pieChartColors[i], fontWeight: FontWeight.w700)),
            );
          }),
    )
        : Text("Option ${selectedIndex+1}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: selectedIndex == - 1 ? Colors.black : pieChartColors[selectedIndex])),
    SizedBox(height: 10),
    Text(selectedIndex == - 1 ? "" : "Votes: ${10 * selectedIndex}", style: TextStyle(fontSize: 40))];

  }


  pieDataBuilder(int selectedIndex) {
    clearUsedColors();
    List<PieChartSectionData> data = [];

    for (int i= 0; i < 6 ; i++){
      pieChartColors.add(generateUniqueColor());
    }

    for (int i = 0; i < 6; i++) {
      data.add(
        PieChartSectionData(
          value: i+1 *2,
          title: '${i+1}',
          titleStyle: selectedIndex == i ? TextStyle(fontSize: 40) : TextStyle(fontSize: 20),
          radius: selectedIndex == i ? 225 : 200,
          color: pieChartColors[i],
        )
      );
    }

    return data;

  }
}











