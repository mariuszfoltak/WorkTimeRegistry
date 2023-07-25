import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_time_tracker/model/client.dart';

import '../model/registered_hour.dart';
import '../repository/dbrepository.dart';

class RegisterHoursScreen extends StatefulWidget {
  const RegisterHoursScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterHoursScreenState();
}

class _RegisterHoursScreenState extends State<RegisterHoursScreen> {
  Map<ClientModel, TextEditingController> projectHoursTextControllers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zarejestruj godziny"),
      ),
      bottomSheet: Container(
        child: MaterialButton(
          color: Colors.green,
          textColor: Colors.white,
          child: const Text('Zapisz'),
          onPressed: () {
            setState(() {
              for (var project in projectHoursTextControllers.keys) {
                if (projectHoursTextControllers[project]!.value.text.isNotEmpty) {
                  var hours = int.parse(projectHoursTextControllers[project]!.value.text);
                  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  var registeredHour = RegisteredHourModel(projectId: project.id!, hours: hours, date: date);
                  DatabaseRepository.instance.insertHours(hour: registeredHour);
                }
              }
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: FutureBuilder<List<ClientModel>>(
        future: DatabaseRepository.instance.getAllProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            projectHoursTextControllers = {};
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var project = snapshot.data![index];
                var textEditingController = TextEditingController();
                projectHoursTextControllers.putIfAbsent(project, () => textEditingController);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(project.name, style: const TextStyle(fontSize: 24)),
                    Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 5),
                      child: TextField(
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                );
              },
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
