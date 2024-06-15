import 'package:flutter/material.dart';
import 'package:notes_app_sqflite_sample/notes_app.dart';
import 'package:notes_app_sqflite_sample/screens/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  int? userId = null;

  prefsLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool(LoginPage.PREFS_LOGGED_IN_KEY)!;
    userId = prefs.getInt(LoginPage.PREFS_USER_ID_KEY);
  }

  @override
  void initState() {
    super.initState();
    prefsLogin();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: loggedIn ? NotesApp(userId: userId!) : LoginPage(),
    );
  }
}

