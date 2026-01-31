import 'package:event_app/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminResult extends StatefulWidget {
  const AdminResult({super.key});

  @override
  State<AdminResult> createState() => _AdminResultState();
}

class _AdminResultState extends State<AdminResult> {

  List<Color> chartColors = [];
  int selectedIndex = 0;
  int chartType = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              color: chartType == 0 ? primaryColor : secondaryColor,
              onPressed: () {
            setState(() {
              chartType = 0;
            });
          }, icon: Icon(Icons.pie_chart)),
          IconButton(
              color: chartType == 1 ? primaryColor : secondaryColor,
              onPressed: () {
            setState(() {
              chartType = 1;
            });
          }, icon: Icon(Icons.bar_chart)),
        ],
        title: Text("Action Name: Action Name"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: isLandscape(context) ? Axis.horizontal : Axis.vertical,
          child: screenSizeHandler(),
        ),
      ),
    );
  }


  screenSizeHandler() {
    return StatefulBuilder(builder: (context, setState) {
      return isLandscape(context) ? Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          chartTypeHandler(setState),
          detailWidget()
        ],
      ) : Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          chartTypeHandler(setState),
          detailWidget()
        ],
      );
    });
  }

  chartTypeHandler(void Function(void Function()) setState){
    if (chartType == 0) {
      return pieChartWidget(setState);
    } else {
      return barChartWidget(setState);
    }
  }

  barChartWidget(void Function(void Function()) setState) {
    return Container(
      height: isLandscape(context) ? (MediaQuery.of(context).size.height) - 200 : 400,
      width:  isLandscape(context) ? (MediaQuery.of(context).size.width / 2) + 100 : null,
      child: BarChart(

          curve: Curves.linear,
          duration: Duration(milliseconds: 250),
          BarChartData(
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      overflow: TextOverflow.ellipsis,
                      'Option ${value.toInt() + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: chartColors[value.toInt()]
                    ));
                  }
              )
            )),
              gridData: FlGridData(
                  drawVerticalLine: false,  // remove vertical lines in the grid
                  getDrawingHorizontalLine: (val){
                    return FlLine(
                      color: Colors.grey.shade400, // Sets the color of horizontal grid lines
                      strokeWidth: 1.0, // Sets the thickness of the grid lines
                    );
                  }
              ),
              barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      try {
                        selectedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
                      } catch(e) {
                        selectedIndex = -1;
                      }
                    });
                  }
              ),
              barGroups: barDataBuilder(selectedIndex)
          )
      ),
    );
  }

  pieChartWidget(void Function(void Function()) setState) {
    return Container(
      height: isLandscape(context) ? (MediaQuery.of(context).size.height) - 200 : 400,
      width:  isLandscape(context) ? (MediaQuery.of(context).size.width / 2) + 100 : null,
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
    return selectedIndex == -1 ?
    Container(
      padding: EdgeInsets.all(20),
      height: isLandscape(context) ? 800 : 400,
      width: isLandscape(context) ? (MediaQuery.of(context).size.width / 2) - 200 : null,
      child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text("President Option", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
              trailing: Text("${i * 20}", style: TextStyle(fontSize: 40, color: chartColors[i], fontWeight: FontWeight.w700)),
            );
          }),
    )
        : Center(
          child: Container(
            height: isLandscape(context) ? 800 : 400,
            width: isLandscape(context) ? (MediaQuery.of(context).size.width / 2) - 200 : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            Text("Option ${selectedIndex+1}", overflow: TextOverflow.ellipsis ,style: TextStyle(fontSize: isLandscape(context) ? 80 : 40, fontWeight: FontWeight.w700, color: selectedIndex == - 1 ? Colors.black : chartColors[selectedIndex])),
            SizedBox(height: 20),
            Text(selectedIndex == - 1 ? "" : "Votes: ${10 * selectedIndex}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isLandscape(context) ? 80 : 40))
                  ],
                ),
          ),
        );

  }


  pieDataBuilder(int selectedIndex) {
    clearUsedColors();
    List<PieChartSectionData> data = [];

    for (int i= 0; i < 6 ; i++){
      chartColors.add(generateUniqueColor());
    }

    for (int i = 0; i < 6; i++) {
      data.add(
        PieChartSectionData(
          value: i+1 *2,
          title: '${i+1}',
          titleStyle: selectedIndex == i ? TextStyle(fontSize: 40) : TextStyle(fontSize: 20),
          radius: selectedIndex == i ? isLandscape(context) ? 400 : 225 : isLandscape(context) ? 350 : 200,
          color: chartColors[i],
        )
      );
    }

    return data;

  }

  barDataBuilder(int selectedIndex) {
    clearUsedColors();
    List<BarChartGroupData> data = [];

    for (int i= 0; i < 6 ; i++){
      chartColors.add(generateUniqueColor());
    }

    for (int i = 0; i < 6; i++) {
      data.add(
          BarChartGroupData(
              groupVertically: true,
            x: i,
            barRods: [
              BarChartRodData(
                borderRadius: BorderRadius.circular(0),
                  width: 50,
                  color: chartColors[i],
                  toY: i+1.toDouble())
            ]
          )
      );
    }

    return data;

  }
}











