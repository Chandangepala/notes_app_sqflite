import 'package:flutter/material.dart';
import 'package:notes_app_sqflite_sample/app_database.dart';
import 'package:notes_app_sqflite_sample/screens/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesApp extends StatefulWidget {
  int userId;
  NotesApp({super.key, required this.userId});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  var titleController = TextEditingController();
  var descController = TextEditingController();

  List<Map<String, dynamic>> notesList = [];

  prefsLogin({required loggedIn, required userId}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.setBool(LoginPage.PREFS_LOGGED_IN_KEY, loggedIn);
    userId = prefs.setInt(LoginPage.PREFS_USER_ID_KEY, userId);
  }

  getNotes({required userId}) async {
    notesList = await AppDatabase.db.fetchAllNotes(userId: userId);
    setState(() {});
  }

  Future<bool> addNotes(String title, String desc) async {
    return await AppDatabase.db.insertNote(title: title, desc: desc, userId: widget.userId);
  }

  Future<bool> deleteNote(int id) async {
    return await AppDatabase.db.deleteNote(id);
  }

  Future<bool> updateNote(Map<String, dynamic> note) {
    return AppDatabase.db.updateNote(note[AppDatabase.COLUMN_NOTE_ID], note);
  }

  @override
  void initState() {
    super.initState();
    getNotes(userId: widget.userId);
    print('${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('N O T E S   A P P'),
        centerTitle: true,
        backgroundColor: Colors.red.shade100,
        actions: [
          IconButton(onPressed: (){
            prefsLogin(loggedIn: false, userId: 0);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: notesList.isEmpty
          ? Center(
              child: Text(
                'No Note Found',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    hoverColor: Colors.red.shade200,
                    onLongPress: () {
                      _showBottomSheet(isUpdate: true, index: index);
                    },
                    leading: CircleAvatar(
                      child: Center(
                        child: Text(
                          notesList[index][AppDatabase.COLUMN_NOTE_TITLE]
                              .toString()
                              .substring(0, 1),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade200),
                        ),
                      ),
                    ),
                    title: Text(notesList[index][AppDatabase.COLUMN_NOTE_TITLE]),
                    subtitle:
                        Text(notesList[index][AppDatabase.COLUMN_NOTE_DESC]),
                    trailing: IconButton(
                        onPressed: () async {
                          var deleted = await deleteNote(
                              notesList[index][AppDatabase.COLUMN_NOTE_ID]);
                          if (deleted) {
                            getNotes(userId: widget.userId);
                          }
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade200,
                        )),
                  ),
                );
              },
              itemCount: notesList.length,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //To show bottom sheet
  _showBottomSheet({bool isUpdate = false, int index = -1}) {
    if (isUpdate) {
      titleController.text = notesList[index][AppDatabase.COLUMN_NOTE_TITLE];
      descController.text = notesList[index][AppDatabase.COLUMN_NOTE_DESC];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5  + MediaQuery.of(context).viewInsets.bottom,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding:  EdgeInsets.only(top: 11 , left: 11, right: 11, bottom:  5 + MediaQuery.of(context).viewInsets.bottom ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isUpdate
                      ? Text(
                          'Update Note',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade200),
                        )
                      : Text(
                          'Add Note',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade200),
                        ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter Note Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2))),
                  ),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter Note Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.red, width: 2))),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            descController.text.isNotEmpty) {
                          bool updated = false;
                          bool inserted = false;
                          if (isUpdate) {
                            updated = await updateNote({
                              AppDatabase.COLUMN_NOTE_ID: notesList[index]
                                  [AppDatabase.COLUMN_NOTE_ID],
                              AppDatabase.COLUMN_NOTE_TITLE:
                                  titleController.text,
                              AppDatabase.COLUMN_NOTE_DESC: descController.text
                            });
                          } else {
                            inserted = await addNotes(
                                titleController.text, descController.text);
                          }

                          if (updated || inserted) {
                            getNotes(userId: widget.userId);
                            titleController.clear();
                            descController.clear();
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.75),
                            content: Text('Missing Title or Description!'),
                            backgroundColor: Colors.red.shade300,
                          ));
                        }
                      },
                      child: Text('Save')),
                  IconButton(
                      onPressed: () {
                        titleController.clear();
                        descController.clear();
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        size: 25,
                        color: Colors.red.shade300,
                      ))
                ],
              ),
            ),
          );
        });
  }
}
