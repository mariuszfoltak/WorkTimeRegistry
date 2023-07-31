import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class RegisteredHours extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get project => integer().references(Projects, #id)();

  IntColumn get hours => integer()();

  TextColumn get date => text()();

  TextColumn get description => text().nullable()();
}

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();

  IntColumn get color => integer()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class RegisteredHourWithProject {
  RegisteredHourWithProject(this.registeredHour, this.project);

  final RegisteredHour registeredHour;
  final Project project;
}

class ProjectWithAggregateHours {
  ProjectWithAggregateHours(this.project, this.hours);

  final Project project;
  final int hours;
}

@DriftDatabase(tables: [Projects, RegisteredHours])
class WTTDatabase extends _$WTTDatabase {
  WTTDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<List<Project>> get allProjects => (select(projects)..orderBy([(t) => OrderingTerm(expression: t.name)])).get();

  Stream<List<Project>> watchProjects() {
    return (select(projects)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<Project> addProject(ProjectsCompanion entry) {
    return into(projects).insertReturning(entry);
  }

  Future<dynamic> removeProject(Project project) async {
    var hoursCount = await (selectOnly(registeredHours)
          ..addColumns([registeredHours.id.count()])
          ..where(registeredHours.project.equals(project.id)))
        .map((p0) => p0.read(registeredHours.id.count()))
        .getSingle();

    if (hoursCount != null && hoursCount > 0) {
      var disabledProject = project.copyWith(isDeleted: true);
      return update(projects).replace(disabledProject);
    }

    return (delete(projects)..where((tbl) => tbl.id.equals(project.id))).go();
  }

  Future<int> addRegisteredHour(RegisteredHoursCompanion entry) {
    return into(registeredHours).insert(entry);
  }

  Future<void> addRegisteredHours(List<RegisteredHoursCompanion> entries) async {
    await batch((batch) => batch.insertAll(registeredHours, entries));
  }

  Future<int> removeRegisteredHour(RegisteredHour entry) {
    return (delete(registeredHours)..where((rh) => rh.id.equals(entry.id))).go();
  }

  Stream<List<RegisteredHourWithProject>> watchRegisteredHours([String? month]) {
    var query = select(registeredHours).join([innerJoin(projects, projects.id.equalsExp(registeredHours.project))]);
    query.orderBy([OrderingTerm.desc(registeredHours.date)]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return RegisteredHourWithProject(
          row.readTable(registeredHours),
          row.readTable(projects),
        );
      }).toList();
    });
  }

  Stream<List<ProjectWithAggregateHours>> watchProjectWithAggregateHoursInMonth(String month) {
    var aggregateHours = registeredHours.hours.sum();
    var query = select(projects).addColumns([aggregateHours]).join(
        [innerJoin(registeredHours, projects.id.equalsExp(registeredHours.project))]);
    query.where(registeredHours.date.like('$month-%'));
    query.groupBy([projects.id]);
    query.orderBy([OrderingTerm.desc(projects.name)]);
    return query.map((row) {
      return ProjectWithAggregateHours(
        row.readTable(projects),
        row.read(aggregateHours)!,
      );
    }).watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
