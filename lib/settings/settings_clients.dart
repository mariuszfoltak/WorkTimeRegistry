import 'package:flutter/material.dart';

class SettingsClientsPage extends StatefulWidget {
  const SettingsClientsPage({super.key});

  @override
  State<SettingsClientsPage> createState() => _SettingsClientsPageState();
}

class _SettingsClientsPageState extends State<SettingsClientsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Klienci"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Klient 1"),
            onTap: () => print("test"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Klient 2"),
            onTap: () => print("Klient 2"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Klient 3"),
            onTap: () => print("Klient 3"),
          ),
        ],
      ),
    );
  }
}
