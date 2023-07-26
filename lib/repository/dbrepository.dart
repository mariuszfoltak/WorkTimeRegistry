import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:work_time_tracker/model/client.dart';
import 'package:work_time_tracker/model/registered_hour.dart';

import '../const/app_const.dart';

class DatabaseRepository {
  static final DatabaseRepository instance = DatabaseRepository._init();
  DatabaseRepository._init();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('work_hours.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
create table ${AppConst.projectsTableName} ( 
  id integer primary key autoincrement,
  name text
)
''');
    await db.execute('''
create table ${AppConst.registeredHoursTableName} ( 
  id integer primary key autoincrement,
  project_id integer,
  hours integer not null,
  date text not null,
  FOREIGN KEY(project_id) REFERENCES ${AppConst.projectsTableName}(id)
)
''');
  }

  Future<void> insert({required ClientModel client}) async {
    try {
      final db = await database;
      db.insert(AppConst.projectsTableName, client.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> insertHours({required RegisteredHourModel hour}) async {
    try {
      final db = await database;
      db.insert(AppConst.registeredHoursTableName, hour.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteHours({required RegisteredHourModel hour}) async {
    try {
      final db = await database;
      db.delete(AppConst.registeredHoursTableName, where: 'id = ?', whereArgs: [hour.id]);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<ClientModel>> getAllProjects() async {
    final db = await instance.database;

    final result = await db.query(AppConst.projectsTableName);
    return result.map((json) => ClientModel.fromJson(json)).toList();
  }

  Future<List<RegisteredHourModel>> getAllRegisteredHours() async {
    final db = await instance.database;

    final clients = await getAllProjects();
    final result = await db.query(AppConst.registeredHoursTableName, orderBy: "date DESC");
    return result.map((json) {
      var hour = RegisteredHourModel.fromJson(json);
      hour.client = clients.firstWhere((c) => c.id == hour.projectId);
      return hour;
    }).toList();
  }
}
