import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/database.dart';

class ProjectSlideableListTile extends StatelessWidget {
  const ProjectSlideableListTile({
    super.key,
    required this.project,
    required this.onDeletePressed,
  });

  final Project project;
  final void Function(BuildContext context) onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: onDeletePressed,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(project.name),
        onTap: () => print(project.name),
      ),
    );
  }
}
