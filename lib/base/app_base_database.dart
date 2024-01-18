part of base;

abstract class Serializable {
  Map<String, dynamic> asMap();

  void fromMap(Map<String, dynamic> data);
}

abstract class Model extends Serializable {
  int? id;

  @override
  void fromMap(Map<String, dynamic> data) {
    data.containsKey('id') ? id = data['id'] : 0;
  }

  @override
  Map<String, dynamic> asMap() {
    Map<String, dynamic> message = {};

    message['id'] = id;
    return message;
  }

  /// [print] permet de débugger son programme
  /// convertie l'appelant en map et l'affiche en [debugPrint]
  void print() => debugPrint(asMap().toString());
}

abstract class Controller<T extends Model> {
  String table;
  Database db;

  Controller(this.table, this.db);

  Future<T> insert(T model) async {
    model.id = await db.insert(table, model.asMap());
    return model;
  }

  Future<int> update(T model) async {
    return await db
        .update(table, model.asMap(), where: 'id = ?', whereArgs: [model.id]);
  }

  Future<int> delete(T model) async {
    return await db.delete(table, where: 'id = ?', whereArgs: [model.id]);
  }
}

mixin BaseDatabaseController on Base {
  static Database? _database;

  int get dbVersion => 1;

  Future<Database> get database async => (_database ?? await _create());

  /// Create the database
  Future<Database> _create() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'db.db');

    _database =
        await openDatabase(
          path,
          version: dbVersion,
          onCreate: onCreatingDatabase,
          onUpgrade: onUpgrade
        );
    return (_database!);
  }

  @protected
  FutureOr<void> onUpgrade(Database db, int oldVersion, int newVersion) async {}

  @protected
  FutureOr<void> onCreatingDatabase(Database db, int version) async {}
}
