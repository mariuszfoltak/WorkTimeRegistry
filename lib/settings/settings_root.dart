import 'package:flutter/material.dart';
import 'package:work_time_tracker/settings/settings.dart';

class SettingsRootPage extends StatelessWidget {
  const SettingsRootPage({super.key});

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
            leading: Icon(Icons.person),
            title: Text("Klienci"),
            onTap: () => Navigator.pushNamed(context, Routes.clients),
          ),
        ],
      ),
    );
  }
}
