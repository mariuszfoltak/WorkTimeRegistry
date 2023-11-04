import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:work_time_tracker/main.dart';
import 'package:work_time_tracker/model/database.dart';
import 'package:work_time_tracker/registered_hours/hours_screen.dart';

// TODO: add updating entries
// TODO: add colors to projects

class RegisteredHoursPage extends StatefulWidget {
  const RegisteredHoursPage({super.key});

  @override
  State<RegisteredHoursPage> createState() => _RegisteredHoursPageState();
}

class _RegisteredHoursPageState extends State<RegisteredHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Godziny"),
      ),
      body: StreamBuilder<List<RegisteredHourWithProject>>(
          stream: database.watchRegisteredHours(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GroupedListView<RegisteredHourWithProject, String>(
                elements: snapshot.data!,
                groupBy: (element) => element.registeredHour.date,
                order: GroupedListOrder.DESC,
                groupSeparatorBuilder: (String groupByValue) {
                  var date = DateTime.parse(groupByValue);
                  var separatorValue = DateFormat('yyyy-MM-dd (EEEE)').format(date);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Text(separatorValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
                itemBuilder: (context, element) {
                  var registeredHour = element.registeredHour;
                  var project = element.project;
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await database.removeRegisteredHour(registeredHour);
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Usunięto wpis dla projektu ${project.name}')),
                              );
                            });
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        )
                      ],
                    ),
                    child: Container(
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: (registeredHour.description != null && registeredHour.description != '') ? Text(registeredHour.description!) : null, // FIXME
                        trailing: CircleAvatar(child: Text("${registeredHour.hours}h")),
                      ),
                    ),
                  );
                },
                padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
              );
            } else {
              return const Text("Loading...");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => Navigator.pushNamed(context, Routes.registerHours),
        tooltip: 'Dodaj godziny',
        child: const Icon(Icons.add),
      ),
    );
  }
}
