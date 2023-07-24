class ClientModel {
  final int? id;
  final String name;

  ClientModel({this.id, required this.name});

  factory ClientModel.fromJson(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
