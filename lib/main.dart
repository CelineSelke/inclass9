import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MaterialApp(
    home: FolderSelectionScreen(),
  ));
}

class FolderSelectionScreen extends StatefulWidget {
  @override
  _FolderSelectionScreenState createState() => _FolderSelectionScreenState();
}

class _FolderSelectionScreenState extends State<FolderSelectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    await _dbHelper.init();
    final folders = await _dbHelper.getFolders();
    setState(() {
      _folders = folders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Card Folder'),
      ),
      body: _folders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return Card(
                  child: ListTile(
                    title: Text(folder['name']),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardGridScreen(
                            folderId: folder['folderID'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createNewFolder(context),
      ),
    );
  }

  Future<void> _createNewFolder(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Create'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dbHelper.insertFolder({'name': controller.text});
                _loadFolders();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class CardGridScreen extends StatefulWidget {
  final int folderId;

  CardGridScreen({required this.folderId});

  @override
  _CardGridScreenState createState() => _CardGridScreenState();
}

class _CardGridScreenState extends State<CardGridScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    await _dbHelper.init();
    final cards = await _dbHelper.queryAllRowsCards();
    setState(() {
      _cards = cards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards in Folder'),
      ),
      body: _cards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // Width/height ratio
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15)),
                          child: Image.asset(
                            card['imageURL'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error)),
                        ),
                      ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          '${card['name']} of ${card['suit']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}