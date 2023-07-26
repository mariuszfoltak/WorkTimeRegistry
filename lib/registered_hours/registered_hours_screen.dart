import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:work_time_tracker/model/registered_hour.dart';
import 'package:work_time_tracker/registered_hours/hours_screen.dart';
import 'package:work_time_tracker/repository/dbrepository.dart';

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
      body: FutureBuilder<List<RegisteredHourModel>>(
          future: DatabaseRepository.instance.getAllRegisteredHours(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GroupedListView<RegisteredHourModel, String>(
                elements: snapshot.data!,
                groupBy: (element) => element.date,
                order: GroupedListOrder.DESC,
                groupSeparatorBuilder: (String groupByValue) {
                  var date = DateTime.parse(groupByValue);
                  String locale = Localizations.localeOf(context).languageCode;
                  var separatorValue = DateFormat('yyyy-MM-dd (EEEE)', locale).format(date);
                  return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: Text(separatorValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                );
                },
                itemBuilder: (context, element) {
                  var hourModel = element;
                  return ListTile(
                    title: Text(hourModel.client!.name),
                    // subtitle: Text(hourModel.date),
                    trailing: CircleAvatar(child: Text("${hourModel.hours}h")),
                  );
                },
                padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
              );
            } else {
              return const Text("Loading...");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.registerHours),
        tooltip: 'Dodaj godziny',
        child: const Icon(Icons.add),
      ),
    );
  }
}
