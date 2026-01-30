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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Action Name: Action Name"),
      ),
      body: Column(
        children: [

          pieChartView()
        ],
      ),
    );
  }

  pieChartView(){
    int selectedIndex = 0;

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Column(
          children: [
            Container(
              height: 400,
              child: PieChart(
                curve: Curves.linear,
                  duration: Duration(milliseconds: 250),
                  PieChartData(
                      pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {

                              if (pieTouchResponse!.touchedSection!.touchedSectionIndex < 0) {
                                selectedIndex = selectedIndex;
                              } else {
                                selectedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                              }
                            });
                          }
                      ),
                      sections: dataBuilder(selectedIndex)
                  )
              ),
            ),

            SizedBox(height: 20),
            Text("Option ${selectedIndex}", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: pieChartColors[selectedIndex])),
            SizedBox(height: 10),
            Text("Votes: ${10 * selectedIndex}", style: TextStyle(fontSize: 40)),

          ],
        );
      },
    );
  }


  dataBuilder(int selectedIndex) {
    clearUsedColors();
    List<PieChartSectionData> data = [];

    for (int i= 0; i < 6 ; i++){
      pieChartColors.add(generateUniqueColor());
    }

    for (int i = 0; i < 6; i++) {
      data.add(
        PieChartSectionData(
          value: i * 3,
          title: '$i',
          titleStyle: selectedIndex == i ? TextStyle(fontSize: 40) : TextStyle(fontSize: 20),
          radius: selectedIndex == i ? 80 : 50,
          color: pieChartColors[i],
        )
      );
    }

    return data;

  }
}











