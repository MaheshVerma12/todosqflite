import 'package:flutter/material.dart';
import 'package:hussainmustafa/database_services.dart';
import 'package:hussainmustafa/task.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  String? _task = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      appBar: AppBar(
        title: Text('My ToDos',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic)),
        backgroundColor: Colors.amber[600],
        centerTitle: true,
      ),
      body: _tasksList(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'My New Task....',
                  ),
                ),
                SizedBox(height: 10),
                MaterialButton(
                  color: Colors.orange[800],
                  onPressed: () {
                    if (_task == null || _task == '') {
                      return;
                    }
                    _databaseService.addTask(_task!);
                    setState(() {
                      _task = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _tasksList() {
    return FutureBuilder(
        future: _databaseService.getTasks(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Do you want to delete this todo?'),
                          actions: [
                            MaterialButton(
                                onPressed: () {
                                  _databaseService.delete(task.id);
                                  Navigator.of(context).pop();
                                  setState(() {});
                                },
                                child: Text('Yes')),
                            MaterialButton(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        ),
                      );
                    },
                    tileColor: Colors.orange[700],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    title: Text(
                      task.content,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    trailing: Checkbox(
                        value: task.status == 1,
                        onChanged: (value) {
                          _databaseService.updateTaskStatus(
                            task.id,
                            value == true ? 1 : 0,
                          );
                          setState(() {});
                        }),
                  ),
                );
              });
        });
  }
}
