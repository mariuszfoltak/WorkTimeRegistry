import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:work_time_tracker/model/client.dart';
import 'package:work_time_tracker/model/registered_hour.dart';
import 'package:work_time_tracker/repository/dbrepository.dart';

class RegisteredHoursPage extends StatefulWidget {
  const RegisteredHoursPage({super.key});

  @override
  State<RegisteredHoursPage> createState() => _RegisteredHoursPageState();
}

class _RegisteredHoursPageState extends State<RegisteredHoursPage> {
  Map<ClientModel, TextEditingController> registeredHours = {};

  Future<void> _displayTextInputDialog(BuildContext context) async {
    registeredHours = {};
    var allClients = await DatabaseRepository.instance.getAllClients();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Zarejestruj godziny'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                children: allClients.map(
                  (c) {
                    var textEditingController = new TextEditingController();
                    registeredHours.putIfAbsent(
                      c,
                      () => textEditingController,
                    );
                    return Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(fontSize: 24),
                        ),
                        Container(
                          width: 50,
                          margin: EdgeInsets.only(right: 5),
                          child: TextField(
                            controller: textEditingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
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
                  allClients.forEach((client) {
                    if (this.registeredHours[client]!.value.text.isNotEmpty) {
                      var hours =
                          int.parse(this.registeredHours[client]!.value.text);
                      var registeredHour = RegisteredHourModel(
                          projectId: client.id!,
                          hours: hours,
                          date: "2023-07-23");
                      DatabaseRepository.instance
                          .insertHours(hour: registeredHour);
                    }
                  });
                  setState(() {
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
        title: Text("Godziny"),
      ),
      body: FutureBuilder<List<RegisteredHourModel>>(
          future: DatabaseRepository.instance.getAllRegisteredHours(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GroupedListView<RegisteredHourModel, String>(
                elements: snapshot.data!,
                groupBy: (element) => element.date,
                groupSeparatorBuilder: (String groupByValue) =>
                    Text(groupByValue),
                itemBuilder: (context, element) {
                  var hourModel = element;
                  return ListTile(
                    title: Text(hourModel.client!.name),
                    subtitle: Text(hourModel.date),
                    trailing: CircleAvatar(child: Text("${hourModel.hours}h")),
                  );
                },
                padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
              );
            } else {
              return Text("Loading...");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        tooltip: 'Dodaj godziny',
        child: const Icon(Icons.add),
      ),
    );
  }
}
