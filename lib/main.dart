import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  late List _toDoList = [];
  late Map<String, dynamic> _lastremoved;
  late int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data!);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = {};
      newTodo["title"] = _toDoController.text;
      _toDoController.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
    });
  }
  Future<void> _refresh()async{
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a,b){
        if (a ["ok"] && !b ["ok"] ) {
          return 1;
        } else if (!a ["ok"] && b["ok"] ) {
          return -1 ;
        } else {
          return 0;
        }
      });
      _saveData();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo List"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
          children: [
      Container(
      padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _toDoController,
              decoration: const InputDecoration(
                labelText: "New Task",
                labelStyle: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addToDo,
            child: const Text("Add"),
            style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.blueAccent)),
          ),
        ],
      ),
    ),
    Expanded(
    child: RefreshIndicator(
    onRefresh: _refresh,
    child:
    ListView.builder(
    padding: const EdgeInsets.only(top: 10.0),
    itemCount: _toDoList.length,
    itemBuilder: buildItem,
    )),
    )]
    ,
    )
    ,
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(Random().nextDouble().toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastremoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa\" ${_lastremoved["title"]}\" removida"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastremoved);
                    _saveData();
                  });
                }),
            duration: const Duration(seconds: 2),
          );
          //ScaffoldMessenger.of(context).showSnackBar(snack);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);

        });
      },
    );
  }

//Cria arquivo json para persistencia
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  //Salva arquivo json para persistencia
  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  // obtem os dados
  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
