import 'package:flutter/material.dart';

enum BUTTONS { RNG, INCREMENT, DECREMENT, RESET, RESET_ALL, DELETE }

class CustomButton extends StatelessWidget {
  final BUTTONS buttonType;
  final onPressed;
  final buttonText;
  final buttonIcon;
  static final Map<BUTTONS, Color> buttonColors = {
    BUTTONS.RNG: Colors.blue,
    BUTTONS.INCREMENT: Colors.green,
    BUTTONS.RESET: Colors.red,
    BUTTONS.RESET_ALL: Colors.redAccent,
    BUTTONS.DECREMENT: Colors.purple,
    BUTTONS.DELETE: Colors.brown,
  };
  late final _buttonStyle;

  CustomButton(
      {required this.buttonType, required this.onPressed, required this.buttonText, this.buttonIcon}) {
    _buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(buttonColors[buttonType]),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      elevation: MaterialStateProperty.all<double>(20.0),
    );
  }


  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        style: _buttonStyle,
        child: (buttonIcon == null) ? Text(buttonText) : Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [buttonIcon, SizedBox(height: 15), Text(buttonText, textAlign: TextAlign.center,)],),
        onPressed: onPressed,
      ),
    );
  }
}