import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:person_picker/backend/JsonLoader.dart';
import 'package:person_picker/model/participant.dart';

class SettingsPanel extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SettingsPanelState();

}

class _SettingsPanelState extends State<SettingsPanel> {

  Widget _darkModeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Enable Dark Mode:"),
        Switch(
            activeColor: Theme
                .of(context)
                .primaryColor,
            value: AdaptiveTheme
                .of(context)
                .mode == AdaptiveThemeMode.dark,
            onChanged: (newVal) {
              if (newVal) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            }
        ),
      ],
    );
  }

  Widget _deleteAllParticipants() {
    return FlatButton(
      child: Text("Remove All Participants"),
      color: Theme.of(context).primaryColor,
      onPressed: () {
        deleteAll();
      },
    );
  }

  Widget _addParticipantButton() {
    return FlatButton(
      child: Text("Add a new Participant"),
      color: Theme.of(context).accentColor,
      onPressed: () {
        showModalBottomSheet(context: context, builder: (context) {
          String participantFName = "";
          String participantLName = "";
          int startingPoints = 0;
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Enter Participant First name..."),
                    onChanged: (value) => participantFName = value,
                  ),
                  SizedBox(height: 20),

                  TextField(decoration: InputDecoration(
                      hintText: "Enter participant Last Name...."),
                      onChanged: (value) => participantLName = value),
                  SizedBox(height: 20),

                  FlatButton(
                    child: Row(mainAxisSize: MainAxisSize.min,children: [Icon(Icons.check), Text("Submit")]),
                    color: Colors.green,
                    onPressed: () {add(new Participant(name: (participantFName + " " + participantLName)));
                      Navigator.of(context).pop();},
                  ),

                ]

            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _darkModeToggle(),
            SizedBox(height: 20),
           // _deleteAllParticipants(),
            //SizedBox(height: 20),
            _addParticipantButton(),
            SizedBox(height: 20),
          ],
        )
    );
  }

}