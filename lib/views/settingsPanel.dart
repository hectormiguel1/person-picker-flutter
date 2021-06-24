import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:person_picker/backend/store.dart';
import 'package:person_picker/model/participant.dart';

class SettingsPanel extends StatefulWidget{
  final dataStore;


  SettingsPanel(this.dataStore);
  @override
  State<StatefulWidget> createState() => _SettingsPanelState(dataStore);

}

class _SettingsPanelState extends State<SettingsPanel> {
  final DataStore _dataStore;
  final _buttonStyle = ButtonStyle(
    shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    elevation: MaterialStateProperty.all<double>(20.0),
  );

  _SettingsPanelState(this._dataStore);

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

    return SizedBox(
      height: 100,
      width: 100,
      child: ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).errorColor)),
        child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.trash),
              SizedBox(width: 10),
              Text("Remove All Participants", textAlign: TextAlign.center,)
            ]),
        onPressed: () {
          _dataStore.deleteAll();
        },
      ),
    );
  }

  Widget _addParticipantButton() {
    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.userPlus),
              SizedBox(height: 10),
              Text("Add a new Participant", textAlign: TextAlign.center,)
            ]),
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

                    ElevatedButton(
                      child: Row(mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.check), Text("Submit")]),
                      onPressed: () {
                        _dataStore.add(new Participant(name: (participantFName +
                            " " + participantLName)));
                        Navigator.of(context).pop();
                      },
                    ),

                  ]

              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataStore>(
      builder: (dataStore) =>
          Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  _darkModeToggle(),
                  SizedBox(height: 20),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_deleteAllParticipants(),
                        SizedBox(width: 50),
                        _addParticipantButton(),
                        SizedBox(width: 50),
                        _addSaveLocalButton(),
                        SizedBox(width: 50),
                        _uploadLocal(),
                      ]),
                  SizedBox(height: 50),

                ],
              )
          ),
    );
  }

  Widget _addSaveLocalButton() {
    return SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange[900])),
        child: Column(mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.save),
          SizedBox(height: 10),
          Text("Save Locally", textAlign: TextAlign.center,)
        ]),
    onPressed: () =>  kIsWeb? _dataStore.saveLocallyFromWeb() : _dataStore.saveLocallyFromDesktop()));
  }

  Widget _uploadLocal() {
    return SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.teal)),
            child: Column(mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.upload),
                  SizedBox(height: 10),
                  Text("Upload Local Participant File", textAlign: TextAlign.center,)
                ]),
            onPressed: () =>  kIsWeb? _dataStore.uploadFromWeb() : _dataStore.openFromDesktop()));
  }

}