import 'package:date_field/date_field.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_time_tracker/main.dart';
import 'package:work_time_tracker/model/database.dart';

// TODO: sort projects by last used date
// TODO: put projects fields in ListTile or something

typedef EntryControllers = ({TextEditingController hour, TextEditingController description});

class RegisterHoursScreen extends StatefulWidget {
  const RegisterHoursScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterHoursScreenState();
}

class _RegisterHoursScreenState extends State<RegisterHoursScreen> {
  Map<Project, EntryControllers> projectHoursTextControllers = {};
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
                List<RegisteredHoursCompanion> entries = [];
                var date = DateFormat('yyyy-MM-dd').format(selectedDate);
                for (var project in projectHoursTextControllers.keys) {
                  var entryControllers = projectHoursTextControllers[project]!;
                  if (entryControllers.hour.value.text.isNotEmpty) {
                    var hours = int.parse(entryControllers.hour.value.text);
                    var description = entryControllers.description.value.text;
                    entries.add(RegisteredHoursCompanion.insert(
                      project: project.id,
                      hours: hours,
                      date: date,
                      description: d.Value(description),
                    ));
                  }
                }
                database.addRegisteredHours(entries).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Zarejestrowano godziny na dzień ${date}')),
                  );
                  Navigator.pop(context, true);
                });
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Project>>(
        future: database.allProjects,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                    )),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var project = snapshot.data![index];
                      var entryControllers = projectHoursTextControllers.putIfAbsent(
                        project,
                        () => (
                          hour: TextEditingController(),
                          description: TextEditingController(),
                        ),
                      );
                      return EntryWidget(
                        project: project,
                        hoursController: entryControllers.hour,
                        descriptionController: entryControllers.description,
                        autofocus: index == 0,
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

class EntryWidget extends StatelessWidget {
  const EntryWidget({
    super.key,
    required this.project,
    required this.hoursController,
    required this.descriptionController,
    required this.autofocus,
  });

  final Project project;
  final TextEditingController hoursController;
  final TextEditingController descriptionController;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(project.name, style: const TextStyle(fontSize: 24)),
              Container(
                width: 70,
                margin: const EdgeInsets.only(right: 5),
                child: TextField(
                  autofocus: autofocus,
                  textInputAction: TextInputAction.next,
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Godziny"),
                ),
              ),
              Expanded(
                child: TextField(
                  textInputAction: TextInputAction.next,
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Opcjonalny opis"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
