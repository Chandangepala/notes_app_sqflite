import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase{
  //Private Constructor (Singleton CLass Creation)
  AppDatabase._();

  static final AppDatabase db = AppDatabase._();

  static const String DBNAME = 'notes.db';
  static const String TABLE_NAME = 'notes_table';
  static const String COLUMN_NOTE_ID = 'note_id';
  static const String COLUMN_NOTE_TITLE = 'note_title';
  static const String COLUMN_NOTE_DESC = 'note_desc';
  
  static const String TABLE_USER = 'user_table';
  static const String COLUMN_USER_ID = 'user_id';
  static const String COLUMN_USER_NAME = 'user_name';
  static const String COLUMN_PASSWORD = 'user_password';

  //Step 1
  Database? mDB;

  //Step 2: getDB
  Future<Database> getDB() async{
    if(mDB != null){
      return mDB!;
    }else{
      mDB = await openDB();
      return mDB!;
    }
  }

  //To open or initialize database
  Future<Database> openDB() async{
    var rootPath = await getApplicationDocumentsDirectory();
    // data/data/com.example.notes_app_sqflite_sample/databases/notes.db
    var dbPath = join(rootPath.path, DBNAME);

    return await openDatabase(dbPath, version: 5,
        //crete DB
        onCreate: (db, version){
          //will be creating all the tables required to maintain in the db
          //Tables

          //run any sql query
          db.execute(
              'create table $TABLE_NAME ($COLUMN_NOTE_ID integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text, $COLUMN_USER_ID integer)'
          );
          
          db.execute(
            'create table $TABLE_USER ($COLUMN_USER_ID integer primary key autoincrement, $COLUMN_USER_NAME text, $COLUMN_PASSWORD text)'
          );
        }
    );
  }

  //queries
  //insert
  Future<bool> insertNote({required String title, required String desc, required int userId}) async{
    var mainDB = await getDB();

    int rowEffect = await mainDB.insert(TABLE_NAME, {
      COLUMN_NOTE_TITLE : title,
      COLUMN_NOTE_DESC: desc,
      COLUMN_USER_ID: userId
    });

    return rowEffect > 0;
  }

  //read or fetch notes
  Future<List<Map<String, dynamic>>> fetchAllNotes({required int userId}) async{
    var mainDB = await getDB();
    List<Map<String, dynamic>> mNotes = [];

    try{
      mNotes = await mainDB.query(TABLE_NAME, where: '$COLUMN_USER_ID = ?', whereArgs: [userId]);
    }catch(e){
      print("Error: ${e.toString()}");
    }

    return mNotes;
  }

  //Update Note
  Future<bool> updateNote(int id, Map<String, dynamic> note) async{
    var mainDB = await getDB();

    int updated = await mainDB.update(TABLE_NAME, note, where: '$COLUMN_NOTE_ID = ?', whereArgs: [id]);
    return updated > 0;
  }

  //Delete Note
  Future<bool> deleteNote(int id) async{
    var mainDB = await getDB();

    int deleted = await mainDB.delete(TABLE_NAME, where: '$COLUMN_NOTE_ID = ?', whereArgs: [id]);
    return deleted > 0;
  }
  
  Future<bool> insertUser({required userName, required password}) async{
    var mainDB = await getDB();
    int rowEffect = await mainDB.insert(TABLE_USER, {
      COLUMN_USER_NAME : userName,
      COLUMN_PASSWORD: password
    });
    
    return rowEffect > 0;
  }
  
  Future<List<Map<String, dynamic>>> userLogin({required userName, required password}) async{
    var mainDB = await getDB();
    List<Map<String, dynamic>> users = await mainDB.query(TABLE_USER, where: '$COLUMN_USER_NAME = ? AND $COLUMN_PASSWORD = ?' ,whereArgs: [userName, password] );
    return users;
  }
}