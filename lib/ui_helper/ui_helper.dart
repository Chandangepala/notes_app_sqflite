import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UI_Helper {
  static Widget customTextField(
      {required TextEditingController mController,
      required String labelText,
      required String hintText,
      required IconData mIcon,
      TextInputType inputType = TextInputType.text,
      bool hide = false}) {
    return TextField(
      controller: mController,
      keyboardType: inputType,
      obscureText: hide,
      decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(mIcon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(14), right: Radius.circular(5)))),
    );
  }
}
