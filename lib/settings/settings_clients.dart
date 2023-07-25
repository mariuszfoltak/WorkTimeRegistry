import 'package:flutter/material.dart';
import 'package:work_time_tracker/model/client.dart';
import 'package:work_time_tracker/repository/dbrepository.dart';

class SettingsClientsPage extends StatefulWidget {
  const SettingsClientsPage({super.key});

  @override
  State<SettingsClientsPage> createState() => _SettingsClientsPageState();
}

class _SettingsClientsPageState extends State<SettingsClientsPage> {
  final TextEditingController _textFieldController = TextEditingController();
  List<ClientModel> clients = [];

  void addClient() async {
    ClientModel client = ClientModel(name: _textFieldController.text);
    await DatabaseRepository.instance.insert(client: client);
  }

  void getClients() async {
    await DatabaseRepository.instance.getAllProjects().then((value) {
      setState(() {
        clients = value;
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  String? valueText;
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Dodaj nowego klienta'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
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
    getClients();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Klienci"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 20,
        ),
        // padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(client.name),
            onTap: () => print(client.name),
          );
        },
        itemCount: clients.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        tooltip: 'Dodaj klienta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
