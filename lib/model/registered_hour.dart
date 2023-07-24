import 'client.dart';

class RegisteredHourModel {
  final int? id;
  final int projectId;
  final int hours;
  final String date;
  ClientModel? client;

  RegisteredHourModel({
    this.id,
    required this.projectId,
    required this.hours,
    required this.date,
  });

  factory RegisteredHourModel.fromJson(Map<String, dynamic> map) {
    return RegisteredHourModel(
      id: map['id'],
      projectId: map['project_id'],
      hours: map['hours'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'hours': hours,
      'date': date,
    };
  }
}
