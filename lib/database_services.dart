import 'package:hussainmustafa/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;
  final String _tasksTableName = 'tasks';
  final String _tasksIdColumnName = 'id';
  final String _tasksContentColumnName = 'content';
  final String _tasksStatusColumnName = 'status';
  DatabaseService._constructor();
  Future<Database?> returnDatabase() async {
    if (_db != null) {
      return _db;
    }
    _db = await getDatabase();
    return _db;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    print('Database path: $databasePath');
    final database = await openDatabase(
      version: 2,
      databasePath,
      onCreate: (db, version) {
        db.execute('''CREATE TABLE tasks (
        $_tasksIdColumnName  INTEGER PRIMARY KEY,
        $_tasksContentColumnName TEXT NOT NULL,
        $_tasksStatusColumnName INTEGER NOT NULL
        )''');
      },
    );
    return database;
  }

  void addTask(String content) async {
    var db = await returnDatabase();
    await db?.insert('tasks', {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    var db = await returnDatabase();
    var data = await db?.query('tasks');
    List<Task> tasks = data!
        .map(
          (e) => Task(
              id: e['id'] as int,
              status: e['status'] as int,
              content: e['content'] as String),
        )
        .toList();
    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await returnDatabase();
    await db?.update(
      'tasks',
      {
        _tasksStatusColumnName: status,
      },
      where: 'id=?',
      whereArgs: [id],
    );
  }

  void delete(int id) async {
    final db = await getDatabase();
    await db.delete(
      'tasks',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
