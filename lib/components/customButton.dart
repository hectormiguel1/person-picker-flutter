import 'package:flutter/material.dart';
import 'package:person_picker/views/mainView.dart';

enum BUTTONS { RNG, INCREMENT, RESET, RESET_ALL }

class CustomButton extends StatelessWidget {
  final BUTTONS buttonType;
  final onPressed;
  final buttonText;
  final buttonIcon;
  static final Map<BUTTONS, Color> buttonColors = {
    BUTTONS.RNG:  Colors.blue,
    BUTTONS.INCREMENT: Colors.green,
    BUTTONS.RESET: Colors.red,
    BUTTONS.RESET_ALL: Colors.redAccent,
  };
  late final _buttonStyle;

  CustomButton({required this.buttonType, required this.onPressed, required this.buttonText, this.buttonIcon}) {
    _buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(buttonColors[buttonType]),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      elevation: MaterialStateProperty.all<double>(20.0),
    );
  }


  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 100,
      child: ElevatedButton(
        style: _buttonStyle,
        child: (buttonIcon == null)? Text(buttonText) : Row( mainAxisSize: MainAxisSize.min, children: [buttonIcon, SizedBox(width: 15), Text(buttonText)],),
        onPressed: onPressed,
      ),
    );
  }
}