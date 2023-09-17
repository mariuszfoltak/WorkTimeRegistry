import 'package:flutter/material.dart';

Future<void> showNewProjectDialog(BuildContext context, void Function(String projectName) onSavePressed) async {
  var textFieldController = TextEditingController();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj nowy projekt'),
          content: TextField(
            autofocus: true,
            controller: textFieldController,
          ),
          actions: <Widget>[
            MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              child: const Text('Anuluj'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: const Text('Zapisz'),
              onPressed: () {
                Navigator.pop(context);
                onSavePressed(textFieldController.text);
              },
            ),
          ],
        );
      });
}
