import 'package:flutter/material.dart';
import 'package:work_time_tracker/main.dart';
import 'package:work_time_tracker/model/database.dart';
import 'package:work_time_tracker/settings/projects/new_project_dialog.dart';
import 'package:work_time_tracker/settings/projects/project_tile.dart';

class SettingsProjectsPage extends StatefulWidget {
  const SettingsProjectsPage({super.key});

  @override
  State<SettingsProjectsPage> createState() => _SettingsProjectsPageState();
}

class _SettingsProjectsPageState extends State<SettingsProjectsPage> {
  void _addProject(String projectName) async {
    var project = ProjectsCompanion.insert(name: projectName, color: Colors.white.value);
    await database.addProject(project);
    setState(() {});
  }

  void _deleteProject(context, project) async {
    await database.removeProject(project).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usunięto projekt ${project.name}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Projekty"),
      ),
      body: StreamBuilder<List<Project>>(
          stream: database.watchProjects(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var projects = snapshot.data!;
              if (projects.isNotEmpty) {
                return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    return ProjectSlideableListTile(
                      project: projects[index],
                      onDeletePressed: (context) => _deleteProject(context, projects[index]),
                    );
                  },
                  itemCount: projects.length,
                );
              } else {
                return const Center(child: Text("Brak projektów. Utwórz nowy naciskając przycisk poniżej."));
              }
            } else {
              return const Center(child: Text("Ładowanie wyników")); // TODO: Maybe some spinner
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewProjectDialog(context, (projectName) => _addProject(projectName)),
        tooltip: 'Dodaj projekt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
