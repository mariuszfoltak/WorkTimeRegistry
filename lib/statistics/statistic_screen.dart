import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:work_time_tracker/main.dart';
import 'package:work_time_tracker/model/database.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _estimate = false;
  var dateinput = TextEditingController();
  var date = DateTime.now();

  int _workingDaysCount = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dateinput.text = DateFormat.yMMMM().format(date);
    var selectedMonth = DateFormat('yyyy-MM').format(date);
    if(_workingDaysCount < 0) {
      DateTime startOfMonth = DateTime(date.year, date.month, 1);
      _workingDaysCount = calculateWorkingDays(startOfMonth);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Statystyki"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: StreamBuilder<List<ProjectWithAggregateHours>>(
                  stream: database.watchProjectWithAggregateHoursInMonth(selectedMonth),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      if(data.isNotEmpty) {
                        var fractionOfMonth = data.map((e) => e.hours).reduce((a, b) => a + b) / (_workingDaysCount*8);
                        double multiplier = _estimate ? fractionOfMonth : 1; // FIXME
                        List<BarChartGroupData> barChartGroupData = createBarChartGroupData(data, multiplier);
                        print('snapshotData ${snapshot.data!.length}');
                        print('barchartGroupData ${barChartGroupData.length}');
                        return BarChart(
                          BarChartData(
                              barGroups: barChartGroupData,
                              gridData: const FlGridData(show: false),
                              alignment: BarChartAlignment.spaceAround,
                              maxY: data.map((e) => e.hours).reduce(max) * (_estimate ? 1.1 / fractionOfMonth : 2),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.transparent,
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 0,
                                    direction: TooltipDirection.bottom,
                                    fitInsideVertically: true,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      var hours = rod.toY.round();
                                      var days = hours ~/ 8;
                                      var restHours = hours % 8;
                                      return BarTooltipItem('${days}d${restHours}h',
                                          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          children: [TextSpan(text: '\r\n(${hours}h)')]);
                                    },
                                  )),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 0.5,
                                    getTitlesWidget: (value, meta) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(data[value.toInt()].project.name),
                                      );
                                    },
                                  ),
                                ),
                              )),
                        );
                      } else {
                        return const Text("Brak danych"); // TODO: replace with some no data info screen
                      }
                    } else {
                      return Text("Loading"); //TODO replace with some loading screen
                    }
                  }),
            ),
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 17),
                        child: TextField(
                          controller: dateinput,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today), //icon of text field
                              labelText: "Wybrany miesiąc" //label text of field
                              ),
                          readOnly: true, //set it true, so that user will not able to edit text
                          onTap: () async {
                            var pickedDate = await showMonthPicker(
                              context: context,
                              initialDate: date,
                            );

                            if (pickedDate != null) {
                              setState(() {
                                date = pickedDate;
                                _workingDaysCount = -1;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: NumberPicker(
                        value: _workingDaysCount,
                        minValue: 0,
                        maxValue: 100,
                        itemWidth: 50,
                        axis: Axis.horizontal,
                        onChanged: (value) => setState(() => _workingDaysCount = value),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  title: Text("Estymuj"),
                  value: _estimate,
                  onChanged: (value) {
                    setState(() {
                      _estimate = (true == value);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> createBarChartGroupData(List<ProjectWithAggregateHours> data, double multiplier) {
    var barChartGroupData = data.asMap().entries.map((e) {
      int idx = e.key;
      var project = e.value;
      return BarChartGroupData(
        x: idx,
        showingTooltipIndicators: [0],
        barRods: [
          BarChartRodData(
            toY: project.hours.toDouble() / multiplier,
            width: 50,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: multiplier == 1.0 ? Colors.green : Colors.greenAccent,
          ),
        ],
      );
    }).toList();
    return barChartGroupData;
  }
}

int calculateWorkingDays(DateTime start) {
  int workingDays = 0;
  for (DateTime date = start; date.month == start.month; date = date.add(Duration(days: 1))) {
    if (date.weekday >= 1 && date.weekday <= 5) {
      workingDays++;
    }
  }
  return workingDays;
}