import 'package:flutter/material.dart';

class CurrentHoursPage extends StatefulWidget {
  const CurrentHoursPage({super.key});

  @override
  State<CurrentHoursPage> createState() => _CurrentHoursPageState();
}

class _CurrentHoursPageState extends State<CurrentHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Godziny"),
      ),
      body: const Center(
        child: Icon(
          Icons.access_time,
          size: 50,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Dodaj godziny clicked"),
        tooltip: 'Dodaj godziny',
        child: const Icon(Icons.add),
      ),
    );
  }
}
