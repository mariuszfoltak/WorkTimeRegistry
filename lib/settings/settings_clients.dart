import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:work_time_tracker/main.dart';
import 'package:work_time_tracker/model/database.dart';

class SettingsClientsPage extends StatefulWidget {
  const SettingsClientsPage({super.key});

  @override
  State<SettingsClientsPage> createState() => _SettingsClientsPageState();
}

class _SettingsClientsPageState extends State<SettingsClientsPage> {
  TextEditingController _textFieldController = TextEditingController();

  void addClient() async {
    var project = ProjectsCompanion.insert(name: _textFieldController.text, color: Colors.white.value);
    await database.into(database.projects).insert(project);
  }

  String? valueText;

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Dodaj nowego klienta'),
            content: TextField(
              autofocus: true,
              controller: _textFieldController,
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Anuluj'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Zapisz'),
                onPressed: () {
                  setState(() {
                    addClient();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Klienci"),
      ),
      body: StreamBuilder<List<Project>>(
          stream: database.watchProjects(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var projects = snapshot.data!;
              return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                // padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await database.removeProject(project).then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Usunięto projekt ${project.name}')),
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
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(project.name),
                      onTap: () => print(project.name),
                    ),
                  );
                },
                itemCount: projects.length,
              );
            }
            return const Text("waiting");
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        tooltip: 'Dodaj klienta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
