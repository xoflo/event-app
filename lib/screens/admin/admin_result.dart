import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminResult extends StatefulWidget {
  const AdminResult({super.key, this.actionRef, this.actionName, this.eventRef});

  final String? actionName;
  final DocumentReference<Map<String, dynamic>>? actionRef;
  final DocumentReference<Map<String, dynamic>>? eventRef;

  @override
  State<AdminResult> createState() => _AdminResultState();
}

class _AdminResultState extends State<AdminResult> {
  List<Color> chartColors = [];
  int selectedIndex = 0;
  ValueNotifier<int> chartType = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              color: chartType.value == 0 ? primaryColor : secondaryColor,
              onPressed: () {
                chartType.value = 0;
              },
              icon: Icon(Icons.pie_chart)),
          IconButton(
              color: chartType.value == 1 ? primaryColor : secondaryColor,
              onPressed: () {
                chartType.value = 1;
              },
              icon: Icon(Icons.bar_chart)),
        ],
        title: Text(widget.actionName!),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Time Remaining : ", style: TextStyle(fontSize: 30)),

          // Active Time Widget Below:

          StreamBuilder(
            stream: widget.actionRef!.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

              return snapshot.connectionState == ConnectionState.waiting
                  ? SizedBox()
                  : StatefulBuilder(builder: (BuildContext context,
                  void Function(void Function()) setState) {

                int timeDisplay = snapshot.data['durationInSeconds'];


                return FutureBuilder(
                    future: getNetworkTime(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime> utcTime) {
                      if (snapshot.data['status'] == "Ongoing") {
                        final startTime = snapshot.data['startTime'];
                        final differenceInSeconds = utcTime.data!
                            .difference(startTime.toDate())
                            .inSeconds;
                        timeDisplay = snapshot.data['durationInSeconds'] -
                            differenceInSeconds;

                        if (timeDisplay <= 0) {
                          widget.actionRef!.update({'status': "Completed"});
                          // Handle Poll Completion
                        }

                        Timer(Duration(seconds: 1), () {
                          setState(() {
                            timeDisplay--;
                          });
                        });
                      }

                      return snapshot.connectionState == ConnectionState.waiting
                          ? Container(
                              height: 10,
                              width: 50,
                              child: LinearProgressIndicator())
                          : Text(secondsToDisplay(timeDisplay),
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                  fontSize: 40, fontWeight: FontWeight.w700));
                    });
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection:
              isLandscape(context) ? Axis.horizontal : Axis.vertical,
          child: screenSizeHandler(),
        ),
      ),
    );
  }

  screenSizeHandler() {
    return StreamBuilder(
        stream: widget.actionRef!.snapshots(),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                )
              : StatefulBuilder(builder: (context, setState) {

            Map<String, dynamic> options = snapshot.data!['options'];


            for (int i = 0; i < options.length ; i++) {
              chartColors.add(generateUniqueColor());
            }

                  return isLandscape(context)
                      ? Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            chartTypeHandler(setState, options),
                            detailWidget(options)
                          ],
                        )
                      : Column(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            chartTypeHandler(setState, options),
                            detailWidget(options)
                          ],
                        );
                });
        });
  }

  chartTypeHandler(
      void Function(void Function()) setState, Map<String, dynamic> options) {
    return ValueListenableBuilder<int>(
      valueListenable: chartType,
      builder: (context, value, _) {
        return value == 0
            ? pieChartWidget(setState, options)
            : barChartWidget(setState, options);
      },
    );
  }

  barChartWidget(
      void Function(void Function()) setState, Map<String, dynamic> options) {
    return Container(
      height: isLandscape(context)
          ? (MediaQuery.of(context).size.height) - 200
          : 400,
      width: isLandscape(context)
          ? (MediaQuery.of(context).size.width / 2) + 100
          : null,
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
                                options['opt$value']['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: chartColors[value.toInt()]));
                          }))),
              gridData: FlGridData(
                  drawVerticalLine: false, // remove vertical lines in the grid
                  getDrawingHorizontalLine: (val) {
                    return FlLine(
                      color: Colors.grey
                          .shade400, // Sets the color of horizontal grid lines
                      strokeWidth: 1.0, // Sets the thickness of the grid lines
                    );
                  }),
              barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      try {
                        selectedIndex =
                            barTouchResponse!.spot!.touchedBarGroupIndex;
                      } catch (e) {
                        selectedIndex = -1;
                      }
                    });
                  }),
              barGroups: barDataBuilder(selectedIndex, options))),
    );
  }

  pieChartWidget(
      void Function(void Function()) setState, Map<String, dynamic> options) {
    return Container(
        height: isLandscape(context)
            ? (MediaQuery.of(context).size.height) - 200
            : 400,
        width: isLandscape(context)
            ? (MediaQuery.of(context).size.width / 2) + 100
            : null,
        child: PieChart(
            curve: Curves.linear,
            duration: Duration(milliseconds: 200),
            PieChartData(
                startDegreeOffset: 30,
                centerSpaceRadius: 0,
                pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        selectedIndex = pieTouchResponse!
                            .touchedSection!.touchedSectionIndex;
                      });
                    }),
                sections: pieDataBuilder(selectedIndex, options))));
  }

  detailWidget(Map<String, dynamic> options) {
    return selectedIndex == -1
        ? Container(
            padding: EdgeInsets.all(20),
            height: isLandscape(context) ? 800 : 400,
            width: isLandscape(context)
                ? (MediaQuery.of(context).size.width / 2) - 200
                : null,
            child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text(options['opt$i']['name'],
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w700)),
                    trailing: Text(options['opt$i']['votes'].toString(),
                        style: TextStyle(
                            fontSize: 40,
                            color: chartColors[i],
                            fontWeight: FontWeight.w700)),
                  );
                }),
          )
        : Center(
            child: Container(
              height: isLandscape(context) ? 800 : 400,
              width: isLandscape(context)
                  ? (MediaQuery.of(context).size.width / 2) - 200
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(options['opt$selectedIndex']['name'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: isLandscape(context) ? 80 : 40,
                          fontWeight: FontWeight.w700,
                          color: chartColors[selectedIndex])),
                  SizedBox(height: 20),
                  Text("Votes: ${options['opt$selectedIndex']['votes']}",
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: isLandscape(context) ? 80 : 40))
                ],
              ),
            ),
          );
  }

  pieDataBuilder(int selectedIndex, Map<String, dynamic> options) {
    clearUsedColors();
    List<PieChartSectionData> data = [];

    final length = options.length;

    for (int i = 0; i < length; i++) {
      data.add(PieChartSectionData(
        value: options['opt$i']['votes'].toDouble(),
        title: options['opt$i']['name'].toString(),
        titleStyle: selectedIndex == i
            ? TextStyle(fontSize: 40)
            : TextStyle(fontSize: 20),
        radius: selectedIndex == i
            ? isLandscape(context)
                ? 400
                : 225
            : isLandscape(context)
                ? 350
                : 200,
        color: chartColors[i],
      ));
    }

    return data;
  }

  barDataBuilder(int selectedIndex, Map<String, dynamic> options) {
    clearUsedColors();
    List<BarChartGroupData> data = [];

    final length = options.length;

    for (int i = 0; i < length; i++) {
      data.add(BarChartGroupData(groupVertically: true, x: i, barRods: [
        BarChartRodData(
            borderRadius: BorderRadius.circular(0),
            width: 50,
            color: chartColors[i],
            toY: options['opt$i']['votes'])
      ]));
    }

    return data;
  }
}
