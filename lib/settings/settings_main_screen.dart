import 'package:flutter/material.dart';
import 'package:work_time_tracker/settings/settings.dart';

class SettingsMainScreen extends StatefulWidget {
  const SettingsMainScreen({super.key});

  @override
  State<SettingsMainScreen> createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Ustawienia"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text("Projekty"),
            trailing: Icon(Icons.navigate_next),
            onTap: () => Navigator.pushNamed(context, Routes.projects),
          ),
        ],
      ),
    );
  }
}
