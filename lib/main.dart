import 'package:flutter/material.dart';
import 'package:inclass8/folders_database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Card Organizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    int folderCount = 4;
    List<String> _folderName = ["0","1","2","3","4","5","6","7"];
    FolderDatabaseHelper folder = FolderDatabaseHelper();
    int rowCount = 0;

    Future<void> _initializeDatabase() async {
      await folder.init(); 
    }

    void deleteFolder(int index){

    }

    void renameFolder(int index){

    }

    Future<void> _getRowCount() async {
      rowCount = await folder.queryRowCount();
    }

    Future<void> setFolderName(int id) async{
        String? folderName = await folder.getFolderNameById(id);
        setState(() {
            _folderName[id] = folderName ?? "Folder not found";
        });
        
    }

    Future<void> _insertNewFolder(String name, int index) async {
      Map<String, dynamic> newFolder = {
        'folder_name': name,
        'timestamp': DateTime.now().toString(),
      };

      setFolderName(index);

      int id = await folder.insert(newFolder);

    }



    void showAddFolderDialog() {
      String newFolderName = "";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Task Name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  newFolderName = value;
                });
              },
              decoration: const InputDecoration(hintText: "Enter Folder Name"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  if (newFolderName.isNotEmpty) {
                    _insertNewFolder(newFolderName, rowCount);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    _insertNewFolder("Hearts",0);
    _insertNewFolder("Spades",1);
    _insertNewFolder("Diamonds",2);
    _insertNewFolder("Clubs",3);
    _getRowCount();

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(folderCount, (int index) => SizedBox(
            key:Key(index.toString()),
            width: 600, 
            height: 100, 
            child:ColoredBox(color: Colors.red, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Text(_folderName[index], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  SizedBox(width: 50, height: 50, child: IconButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.white,
                    onPressed: () => renameFolder(index),
                    icon: Icon(Icons.recycling),
                    
                  ),),
                  SizedBox(width: 50, height: 50, child: IconButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.white,
                    onPressed: () => deleteFolder(index),
                    icon: Icon(Icons.restore_from_trash),
                    
                  ),)
                ],
              ),
              )
            )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddFolderDialog,
        child: const Text("Add\nTask"),
      ),

    );
  }
}
