import 'package:flutter/material.dart';
import 'package:notes_app_sqflite_sample/app_database.dart';
import 'package:notes_app_sqflite_sample/notes_app.dart';
import 'package:notes_app_sqflite_sample/screens/login/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui_helper/ui_helper.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  static const String PREFS_LOGGED_IN_KEY = "LOGGED_IN_KEY";
  static const String PREFS_USER_ID_KEY = 'USER_ID_KEY';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  List<Map<String, dynamic>> usersList = [];


  prefsLogin({required loggedIn, required userId}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.setBool(LoginPage.PREFS_LOGGED_IN_KEY, loggedIn);
    userId = prefs.setInt(LoginPage.PREFS_USER_ID_KEY, userId);
  }

  Future<bool> userSignIn({required userName, required password}) async {
    usersList =
        await AppDatabase.db.userLogin(userName: userName, password: password);

    for(int i = 0; i < usersList.length; i++){
      print('${usersList[i]}');
    }

    await prefsLogin(loggedIn: usersList.isNotEmpty, userId: usersList[0][AppDatabase.COLUMN_USER_ID]);

    return usersList.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UI_Helper.customTextField(
                  mController: userNameController,
                  labelText: 'User Name',
                  hintText: 'Enter First Name',
                  mIcon: Icons.text_fields),
              UI_Helper.customTextField(
                  mController: passwordController,
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  mIcon: Icons.password,
                  hide: true),
              ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.resolveWith(
                          (states) => Size.fromWidth(330)),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.red.shade300)),
                  onPressed: () async {
                    if (userNameController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      bool signedIn = await userSignIn(
                          userName: userNameController.text,
                          password: passwordController.text);
                      if (signedIn) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotesApp(
                                    userId: usersList[0]
                                        [AppDatabase.COLUMN_USER_ID])));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Incorrect Username or Password!'))
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Username or Password Missing!'))
                      );
                    }
                  },
                  child: Text('Sign In')),
              ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.resolveWith(
                          (states) => Size.fromWidth(330)),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.red.shade200)),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()));
                  },
                  child: Text('Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
