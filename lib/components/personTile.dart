import 'package:flutter/material.dart';

class PersonTile extends StatelessWidget {
  final person;
  final onPressed;
  final isSelected;

  PersonTile(
      {@required this.person, @required this.onPressed, @required this.isSelected});

  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 0.0, 10.0, 0.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          title: Text(person.name,
              style: this.isSelected ? Theme
                  .of(context)
                  .textTheme
                  .button : Theme
                  .of(context)
                  .textTheme
                  .bodyText1),
          leading: Icon(Icons.person),
          selected: this.isSelected,
          selectedTileColor: Theme
              .of(context)
              .selectedRowColor,
          hoverColor: Theme
              .of(context)
              .selectedRowColor
              .withOpacity(0.3),
          onTap: onPressed,
        ));
  }
}