import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'cards';
  static const foldersTable = 'folders';
  static const columnFolderId = 'folderID';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnSuit = 'suit';
  static const columnURL = 'imageURL';
  late Database _db;
// this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
  // Create folders table
  await db.execute('''
    CREATE TABLE folders (
      folderID INTEGER PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''');

  // Create cards table
  await db.execute('''
    CREATE TABLE cards (
      _id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      suit TEXT NOT NULL,
      imageURL TEXT NOT NULL,
      folderID INTEGER,
      FOREIGN KEY (folderID) REFERENCES folders (folderID) ON DELETE CASCADE
    )
  ''');

  // Insert default folders
  final folders = [
    {'name': 'Standard Deck'},
    {'name': 'Hearts'},
    {'name': 'Diamonds'},
    {'name': 'Clubs'},
    {'name': 'Spades'},
  ];
  
  // Insert folders and get their IDs
  final folderIds = <int>[];
  for (final folder in folders) {
    final id = await db.insert(foldersTable, folder);
    folderIds.add(id);
  }

  // Insert all 52 cards into their respective folders
  const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
  const ranks = ['Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 
    'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King'];

  final batch = db.batch();
  for (var i = 0; i < suits.length; i++) {
    final suit = suits[i];
    final folderId = folderIds[i + 1]; // Skip Standard Deck (index 0)
    
    for (final rank in ranks) {
      batch.insert('cards', {
        'name': rank,
        'suit': suit,
        'imageURL': 'assets/cards/${rank.toLowerCase()}_of_$suit.png',
        'folderID': folderId,
      });
    }
  }
  await batch.commit();
}

// Helper methods
// Inserts a row in the database where each key in the
//Map is a column name
// and the value is the column value. The return value
//is the id of the
// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

// All of the rows are returned as a list of maps, where each map is
// a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

// All of the methods (insert, query, update, delete) can also be done using
// raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<List<Map<String, dynamic>>> queryAllRowsCards() async {
    return await _db.query('cards');
  }

// We are assuming here that the id column in the map is set. The other
// column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

// Deletes the row specified by the id. The number of affected rows is
// returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _db.query('folders');
  }

  Future<int> insertFolder(Map<String, dynamic> folder) async {
    return await _db.insert(foldersTable, folder);
  }

  Future<List<Map<String, dynamic>>> getCardsInFolder(int folderId) async {
    return await _db.query(
      'cards',
      where: 'folderID = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> deleteFolder(int id) async {
    return await _db.delete(
      foldersTable,
      where: '$columnFolderId = ?',
      whereArgs: [id],
    );
  }
}
