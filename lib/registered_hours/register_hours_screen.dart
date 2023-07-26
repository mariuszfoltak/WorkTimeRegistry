import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_time_tracker/model/client.dart';

import '../model/registered_hour.dart';
import '../repository/dbrepository.dart';

// TODO: add saving description
// TODO: sort projects by last used date
// TODO: put projects fields in ListTile or something
// TODO: format date field with locales

class RegisterHoursScreen extends StatefulWidget {
  const RegisterHoursScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterHoursScreenState();
}

class _RegisterHoursScreenState extends State<RegisterHoursScreen> {
  Map<ClientModel, TextEditingController> projectHoursTextControllers = {};
  var selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zarejestruj godziny"),
      ),
      bottomSheet: Container(
        height: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              focusNode: FocusNode(skipTraversal: true),
              height: 50,
              minWidth: double.infinity,
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('Zapisz'),
              onPressed: () {
                setState(() {
                  for (var project in projectHoursTextControllers.keys) {
                    if (projectHoursTextControllers[project]!.value.text.isNotEmpty) {
                      var hours = int.parse(projectHoursTextControllers[project]!.value.text);
                      String date = DateFormat('yyyy-MM-dd').format(selectedDate);
                      var registeredHour = RegisteredHourModel(projectId: project.id!, hours: hours, date: date);
                      DatabaseRepository.instance.insertHours(hour: registeredHour);
                    }
                  }
                  Navigator.pop(context, true);
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<ClientModel>>(
        future: DatabaseRepository.instance.getAllProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            projectHoursTextControllers = {};
            return Column(
              children: [
                SizedBox(
                    width: 300,
                    child: DateTimeField(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Data',
                      ),
                      dateFormat: DateFormat("yyyy-MM-dd (EEEE)"),
                      mode: DateTimeFieldPickerMode.date,
                      selectedDate: selectedDate,
                      onDateSelected: (DateTime value) {
                        setState(() {
                          selectedDate = value;
                        });
                      },
                    )
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var project = snapshot.data![index];
                      var textEditingController = TextEditingController();
                      projectHoursTextControllers.putIfAbsent(project, () => textEditingController);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(project.name, style: const TextStyle(fontSize: 24)),
                                Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 5),
                                  child: TextField(
                                    autofocus: index == 0,
                                    textInputAction: TextInputAction.next,
                                    controller: textEditingController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: "Godziny"),
                                  ),
                                ),
                                const Expanded(child: TextField(
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(labelText: "Opcjonalny opis"),
                                )),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            // TODO: co wyświetlać w trakcie ładowania? co wyświetlać kiedy brak projektów?
            return const Text("Empty");
          }
        },
      ),
    );
  }
}
