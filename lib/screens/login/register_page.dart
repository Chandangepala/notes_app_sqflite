import 'package:flutter/material.dart';
import 'package:notes_app_sqflite_sample/app_database.dart';
import 'package:notes_app_sqflite_sample/screens/login/login_page.dart';
import 'package:notes_app_sqflite_sample/ui_helper/ui_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPassController = TextEditingController();


  Future<bool> userSignUp(String userName, String password) async {
    bool inserted =
        await AppDatabase.db.insertUser(userName: userName, password: password);
    return inserted;
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
                  mController: firstNameController,
                  labelText: 'First Name',
                  hintText: 'Enter First Name',
                  mIcon: Icons.text_fields),
              UI_Helper.customTextField(
                  mController: lastNameController,
                  labelText: 'Last Name',
                  hintText: 'Enter Last Name',
                  mIcon: Icons.text_fields),
              UI_Helper.customTextField(
                  mController: passwordController,
                  labelText: 'Password',
                  hintText: 'Create Password',
                  mIcon: Icons.password,
                  hide: true),
              UI_Helper.customTextField(
                  mController: confirmPassController,
                  labelText: 'Confirm Password',
                  hintText: 'Re-Enter Password',
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
                  onPressed: () async{
                    if (firstNameController.text.isNotEmpty &&
                        lastNameController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {

                      if (passwordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password is too short!')));
                        return;
                      }
                      if (passwordController.text !=
                          confirmPassController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Password & Confirm Password Doesn\'t Match!')));
                        return;
                      }

                      var userName =
                          '${firstNameController.text}_${lastNameController.text}';
                      var password = passwordController.text;
                      bool signedUp = await userSignUp(userName, password);
                      if(signedUp){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      }
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Required Field Is Missing!')));
                    }
                  },
                  child: Text('Sign Up')),
              ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.resolveWith(
                          (states) => Size.fromWidth(330)),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.red.shade200)),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('Sign In')),
            ],
          ),
        ),
      ),
    );
  }
}
